import { LightningElement, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import US_DATA_CHANNEL from '@salesforce/messageChannel/usDataMessageChannel__c';

export default class UsDataDisplay extends LightningElement {
    usData;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscription = subscribe(
            this.messageContext,
            US_DATA_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

    handleMessage(message) {
        if (message && message.usData) {
            const data = JSON.parse(message.usData);
            if (data && data.countryAbbreviation === 'US') {
                this.usData = data;
            } else {
                this.usData = null; 
            }
        } else {
            this.usData = null;
        }
    }

    get country() {
        return this.usData?.country || '';
    }

    get places() {
        return this.usData?.places || [];
    }

    get hasPlaces() {
        return this.places.length > 0;
    }

    disconnectedCallback() {
        if (this.subscription) {
            this.subscription = null;
        }
    }
}