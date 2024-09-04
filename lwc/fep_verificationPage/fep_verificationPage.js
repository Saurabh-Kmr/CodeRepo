import { LightningElement, api, wire } from 'lwc';
import handleVerification from '@salesforce/apex/Fep_loginandverification.handleVerification';
import verifySelfRegistration from '@salesforce/apex/FEP_NewLoginPageController.verifySelfRegistration';
import handleResend from '@salesforce/apex/Fep_loginandverification.handleResend'
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import basePath from '@salesforce/community/basePath';
import { reduceErrors } from 'c/ldsUtils';

export default class Fep_verificationPage extends NavigationMixin(LightningElement) {
    code;
    identifier;
    method;
    operation;
    userId;
    isLoaded = true;
    @api encryptedVerificationKey;
    enableResend;
    verificationMode;
    errorMessage

    connectedCallback() {
        console.log('encryptedVerificationKey' + this.encryptedVerificationKey);
    }
    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        if (currentPageReference) {
            this.identifier = currentPageReference.state.identifier || null;
            this.method = currentPageReference.state.method || null;
            this.operation = currentPageReference.state.operation || 'SelfRegister';
            this.userId = currentPageReference.state.userId || null;
            this.enableResend = this.operation === 'existing' ? true : false;
            this.verificationMode = this.method === 'mobile' ? 'mobile phone' : 'email address';

        }
    }

    handleChange(event) {
        try {
            this.code = event.target.value;
        }
        catch (error) {
            console.error(error.message);
        }
    }

    async handleVerification() {
        try {
            this.isLoaded = false;
            if(!this.code){
                this.errorMessage='Please provide the verification code.';
                this.isLoaded=true;
            }
            else if (this.operation === 'SelfRegister') {
                let redirect = await verifySelfRegistration({ method: this.method, identifier: this.identifier, code: this.code, startUrl: `${basePath}/verifymobile` });
                this.isLoaded = true;
                if (redirect) {
                    this[NavigationMixin.GenerateUrl]({
                        type: 'standard__webPage',
                        attributes: {
                            url: `${redirect}`
                        }
                    }).then(url => {
                        window.open(url, "_self");
                    })
                }
            }
            else {

                let data = await handleVerification({ userId: this.userId, method: this.method, identifier: this.identifier, code: this.code, startUrl: `${basePath}` });
                this.isLoaded = true;
                if (data) {
                    this[NavigationMixin.GenerateUrl]({
                        type: 'standard__webPage',
                        attributes: {
                            url: `${data}`
                        }
                    }).then(url => {
                        window.open(url, "_self")
                    });
                }

            }

        }
        catch (error) {
            this.isLoaded = true;
            this.errorMessage = reduceErrors(error)[0]
            console.error(reduceErrors(error)[0]);
        }
    }

    async handleResend() {
        try {
            console.log('clicked')
            let data = await handleResend({ userId: this.userId, verificationMode: this.method });
            if (data) {
                var loginMetadata = JSON.parse(data);
                console.log(data)
                if (loginMetadata.isSuccess) {
                    this.errorMessage = null;
                    this[NavigationMixin.Navigate]({
                        type: 'standard__webPage',
                        attributes: {
                            url: `${basePath}/verifyidentity?identifier=${loginMetadata.identifier}&operation=existing&method=${this.method}&userId=${loginMetadata.userId}`
                        }
                    });
                }
            }

        } catch (error) {
            this.data = null;
            this.errorMessage = reduceErrors(error)[0];
            console.error(reduceErrors(error)[0]);
        }


    }

    handleAlert() {
        this.errorMessage = null;
    }
}