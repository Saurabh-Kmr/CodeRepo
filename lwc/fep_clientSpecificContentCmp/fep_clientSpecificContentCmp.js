import { LightningElement, wire, api } from 'lwc';
import { reduceErrors } from 'c/ldsUtils';
import isGuest from "@salesforce/user/isGuest";
import id from '@salesforce/user/Id';
import getCoachList from '@salesforce/apex/FEP_GetClientContent.getContent';
import { CurrentPageReference } from "lightning/navigation";
export default class Fep_clientSpecificContentCmp extends LightningElement {
    @api
    fieldToDisplay;
    errorMessage;
    result

    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        if (currentPageReference && currentPageReference.state.view==="editor") {
            this.result = `Personalized Content for ${this.fieldToDisplay.trim()} to be displayed on site after login.`;
        }
    }

    async connectedCallback() {
        try {
            if (!isGuest) {
                let fieldApiName = this.fieldToDisplay.trim();
                let data = await getCoachList({ userId: id, field: fieldApiName });
                if (data !== null) {
                    this.result = data;
                }
            }
        } catch (error) {
            this.errorMessage = reduceErrors(error);
            console.error(this.errorMessage);
        }
    }

}