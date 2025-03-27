import { LightningElement, track, wire } from 'lwc';
import getCountryMappings from '@salesforce/apex/CountryMappingController.getCountryMappings';
import getZipCodeData from '@salesforce/apex/CountryMappingController.getZipCodeData';
import saveNonUSData from '@salesforce/apex/CountryMappingController.saveNonUSData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { publish, MessageContext } from 'lightning/messageService';
import US_DATA_CHANNEL from '@salesforce/messageChannel/usDataMessageChannel__c';

export default class CountryZipCodeLookup extends LightningElement {
    @track countryCode = '';
    @track zipCode = '';
    @track responseData = null;
    @track countryOptions = [];
    @track isLoading = false;
    @track errorMessage = '';

    @wire(getCountryMappings)
    wiredCountryMappings({ error, data }) {
        if (data) {
            this.countryOptions = data.map(country => ({
                label: country.label,
                value: country.value
            }));
        } else if (error) {
            this.showToast('Error', 'Failed to load country mappings', 'error');
            console.error('Country mappings error:', error);
        }
    }

    @wire(MessageContext)
    messageContext;

    handleCountryChange(event) {
        this.countryCode = event.target.value;
        this.clearError();
    }

    handleZipCodeChange(event) {
        this.zipCode = event.target.value;
        this.clearError();
    }

    async searchZipCode() {
        if (!this.validateInputs()) {
            return;
        }

        this.isLoading = true;
        this.clearError();

        try {
            const result = await getZipCodeData({ 
                countryCode: this.countryCode, 
                zipCode: this.zipCode 
            });

            if (result) {
                if (result.isSuccess) {
                    this.processResponse(result);
                } else {
                    this.showError(result.errorMessage);
                }
            } else {
                this.showError('No data returned from ZIP code search');
            }
        } catch (error) {
            this.handleError(error, 'Error retrieving ZIP code data');
        } finally {
            this.isLoading = false;
        }
    }

    validateInputs() {
        if (!this.countryCode && !this.zipCode) {
            this.showError('Please select a country and enter a ZIP code');
            return false;
        }
        if (!this.countryCode) {
            this.showError('Please select a country');
            return false;
        }
        if (!this.zipCode) {
            this.showError('Please enter a ZIP code');
            return false;
        }
        return true;
    }

    processResponse(data) {
        this.responseData = data;
        if (data.countryAbbreviation === 'US') {
            this.publishUsData(data);
            this.showToast('Success', 'US ZIP code data retrieved successfully', 'success');
        } else {
            this.publishUsData(null);
            this.storeNonUSData(data);
        }
    }

    publishUsData(data) {
        const message = {
            usData: JSON.stringify(data)
        };
        publish(this.messageContext, US_DATA_CHANNEL, message);
    }

    async storeNonUSData(data) {
        this.isLoading = true;
        try {
            const success = await saveNonUSData({ 
                country: data.country, 
                city: data.places?.[0]?.placeName || 'Unknown',
                state :  data.places?.[0]?.state || 'Unknown'
            });
            if (success) {
                this.showToast('Success', 'Non-US data saved successfully', 'success');
            }
        } catch (error) {
            this.handleError(error, 'Error saving non-US data');
        } finally {
            this.isLoading = false;
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant,
        });
        this.dispatchEvent(event);
    }

    showError(message) {
        this.errorMessage = message;
    }

    clearError() {
        this.errorMessage = '';
    }

    handleError(error, context) {
        const errorMessage = error.body?.message || error.message || 'An unexpected error occurred';
        this.showError(`${context}: ${errorMessage}`);
        console.error(context, error);
    }
}