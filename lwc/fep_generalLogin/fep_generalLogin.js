import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import verifyContactExists from '@salesforce/apex/FEP_NewLoginPageController.verifyContactExists';
import basePath from '@salesforce/community/basePath';
import { reduceErrors } from 'c/ldsUtils';
export default class Fep_generalLogin extends NavigationMixin(LightningElement) {
    errorMessage;
    recordFields;
    defaultVerificationMethod = 'email';
    isLoaded = true;
    contactUsLink;
    hrefTag;
    emailRegex = '[a-zA-Z0-9._%+\\-]+@[a-zA-Z0-9.\\-]+\\.[a-zA-Z]{2,}$';
    mobileRegex = "[0-9]{3}-[0-9]{3}-[0-9]{4}";


    handleInputChange(event) {
        if (event.target.dataset.name === 'Phone') {
            const target = event.target;
            const input = event.target.value.replace(/\D/g, '').substring(0, 10); // First ten digits of input only
            const zip = input.substring(0, 3);
            const middle = input.substring(3, 6);
            const last = input.substring(6, 10);
            if (input.length > 6) { target.value = `${zip}-${middle}-${last}`; }
            else if (input.length > 3) { target.value = `${zip}-${middle}`; }
            this.inputValue = event.target.value;
        }

    }

    async handleSignUp(event) {
        try {

            let verificationMethod = this.defaultVerificationMethod;
            event.preventDefault();
            const userInputs = this.template.querySelectorAll('[data-type="user-input"]');
            const allValid = [
                ...userInputs,
            ].reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);

            if (allValid) {
                this.isLoaded = false;
                const fieldMap = new Map();
                userInputs.forEach(input => {
                    if (input.dataset.name === 'Phone') {
                        let phoneValue = '+1 ' + input.value.replaceAll('-', "");
                        fieldMap.set(input.dataset.name, phoneValue);
                    }
                    else {
                        fieldMap.set(input.dataset.name, input.value);
                    }
                });
                let isSuccess = await verifyContactExists({ firstName: fieldMap.get('FirstName'), lastName: fieldMap.get('LastName'), phone: fieldMap.get('Phone'), email: fieldMap.get('Email'), veriMethod: verificationMethod, isGeneral: true, companyName: fieldMap.get('Company') });
                let successData = JSON.parse(isSuccess);
                console.log(isSuccess);
                this.isLoaded = true
                if (successData.isSuccess === true) {
                    this[NavigationMixin.Navigate]({
                        type: 'standard__webPage',
                        attributes: {
                            url: `${basePath}/verifyidentity?identifier=${successData.url}&operation=${successData.operation}&method=${successData.method}`
                        }
                    });
                }
                else if (successData.url === null || successData.url === '/login') {
                    this.errorMessage = successData.url === null ? 'The email address you entered is not registered with us. Please enter the email your employer uses for communications. If you are still having issues please click here to contact us. ' : 'A user with the specified email address is already registered. ';
                    this.contactUsLink = successData.url === null ? `${basePath}/contact-us` : `${basePath}/login`;
                    this.hrefTag = successData.url === null ? 'please click here to contact us' : 'Please use the login page to continue.';
                }
                else {
                    this[NavigationMixin.Navigate]({
                        type: 'standard__webPage',
                        attributes: {
                            url: `${basePath}${successData.url}`
                        }
                    });
                }

            }
        }
        catch (error) {
            this.isLoaded = true
            this.errorMessage = reduceErrors(error);

            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: `${basePath}/error`
                }
            })
            console.log(error.stack);
            console.error(this.errorMessage);
        }


    }

    handleExistingUser() {
        try {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: `${basePath}/login`
                }
            });
        }
        catch (error) {
            console.error(reduceErrors(error));
        }
    }

    handleAlert() {
        this.errorMessage = null;
    }

}