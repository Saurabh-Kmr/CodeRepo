import { LightningElement,api } from 'lwc';

export default class Fep_coachCard extends LightningElement {
    @api recordId;
    @api appointment;
    
    connectedCallback(){
        //this.serviceResourceOutputId = this.serviceResourceInputId;
        console.log('appointment'+this.appointment)
    }
    handleCardClick(event){
        console.log('data id'+event.target.dataset.id)
        if(event.target?.dataset?.id){
            const coachEvent = new CustomEvent('coachchange', {
                detail: {coachId:event.target.dataset.id}
                });
                this.dispatchEvent(coachEvent);
            }
        }
}