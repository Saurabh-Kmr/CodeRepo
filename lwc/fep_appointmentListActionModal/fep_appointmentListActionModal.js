import { LightningElement,api } from 'lwc';
import LightningModal from 'lightning/modal';
export default class Fep_appointmentListActionModal extends LightningModal {
    @api content;

    connectedCallback(){
        console.log('content',this.content.coachId)
    }
}