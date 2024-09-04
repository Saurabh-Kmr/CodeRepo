import { LightningElement, api } from 'lwc';


export default class KSC_TwoColumnLayoutComponent extends LightningElement {
    jsonParse = '';
    @api lstDisplay =[];
    
    //Method to handle show tooltip
    showToolTip(event) {
        let tooltipId = event.target.getAttribute("data-name");
        let element = this.template.querySelector(
            `[data-tooltip-id="${tooltipId}"]`
        );
        element.classList.remove("slds-fall-into-ground");
        element.classList.add("slds-rise-from-ground");
    }

    //Method to handle hide tooltip
    hideToolTip(event) {
        let tooltipId = event.target.getAttribute("data-name");
        let element = this.template.querySelector(
            `[data-tooltip-id="${tooltipId}"]`
        );
        element.classList.add("slds-fall-into-ground");
        element.classList.remove("slds-rise-from-ground");
    }
   
}