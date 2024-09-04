import { LightningElement,wire } from 'lwc';
import { NavigationMixin,CurrentPageReference } from 'lightning/navigation';
import loginCreationFields from '@salesforce/apex/FEP_NewLoginPageController.loginCreationFields';
import verifyContactExists from '@salesforce/apex/FEP_NewLoginPageController.verifyContactExists';
import basePath from '@salesforce/community/basePath';

export default class Fep_newLoginPage extends NavigationMixin(LightningElement) {
    errorMessage;
    recordFields;
    OPTIONS = [
        { label: 'SMS', value: 'mobile' },
        { label: 'Email', value: 'email' },
    ];
    defaultVerificationMethod = 'email';
    selectedVerificationMethod;
    isLoaded = false;
    contactUsLink;
    hrefTag;
    email;
    async connectedCallback() {
        try {
            const fields = await loginCreationFields({ sobjectName: 'Contact', fSName: 'fep_newLoginPageFields' });
            this.recordFields = JSON.parse(fields);
            this.recordFields.forEach(field => {
                if (field.type === 'phone') {
                    field.type = 'tel';
                    field.label = 'Mobile',
                        field.pattern = '[0-9]{3}-[0-9]{3}-[0-9]{4}',
                        field.placeholder = '999-999-9999',
                        field.pattrenMissMatch ='Incorrect phone format. Please enter a 10 digit mobile phone in correct format 999-999-9999'
                }
                if (field.type === 'email') {
                    field.pattern = '[a-zA-Z0-9._%+\\-]+@[a-zA-Z0-9.\\-]+\\.[a-zA-Z]{2,}$',
                    field.placeholder = 'user@company.com',
                    field.pattrenMissMatch ='Incorrect email format'
                    field.value = this.email?this.email:null;
                }
            });
            this.isLoaded = true;
        }
        catch (error) {
            this.isLoaded = true;
            console.error(error.message);
        }
    }

    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        if (currentPageReference) {
             this.email = currentPageReference.state?.email || null;
        }
    }
   /* handleRadioChange(event) {
        try {
            this.selectedVerificationMethod = event.detail.value;
        }
        catch (error) {
            console.error(error.message);
        }
    }*/

    handleInputChange(event){
        if(event.target.dataset.name=== 'Phone'){
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
           
            let verificationMethod = this.selectedVerificationMethod ? this.selectedVerificationMethod : this.defaultVerificationMethod;
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
                        let phoneValue = '+1 ' +input.value.replaceAll('-',"");
                        fieldMap.set(input.dataset.name, phoneValue);
                    }
                    else {
                        fieldMap.set(input.dataset.name, input.value);
                    }
                });
                let isSuccess = await verifyContactExists({ firstName: fieldMap.get('FirstName'), lastName: fieldMap.get('LastName'), phone: fieldMap.get('Phone'), email: fieldMap.get('Email'), veriMethod: verificationMethod ,isGeneral: false,companyName:''});
                let successData = JSON.parse(isSuccess);
                console.log(isSuccess);
                this.isLoaded = true
                if(successData.isSuccess===true){
                    this[NavigationMixin.Navigate]({
                        type: 'standard__webPage',
                        attributes: {
                            url: `${basePath}/verifyidentity?identifier=${successData.url}&operation=${successData.operation}&method=${successData.method}`
                        }
                    });
                }
                else if(successData.url===null ||successData.url==='/login'  ){
                    this.errorMessage = successData.url===null? 'The email address you entered is not registered with us. Please enter the email your employer uses for communications. If you are still having issues please click here to contact us. ':'A user with the specified email address is already registered. ';
                    this.contactUsLink= successData.url===null?`${basePath}/contact-us`:`${basePath}/login`;
                    this.hrefTag = successData.url===null?'please click here to contact us': 'Please use the login page to continue.';
                }
                else{
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
          this.errorMessage = error.body.message;
          this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: `${basePath}/error`
                }
            })
            console.log(error.stack);
            console.error(error.body.message);
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
            console.error(error.message);
        }
    }

    handleAlert() {
        this.errorMessage = null;
    }

}