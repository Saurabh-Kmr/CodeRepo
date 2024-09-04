import { LightningElement } from 'lwc';
import handleLoginAndVerification from '@salesforce/apex/Fep_loginandverification.handleLoginAndVerification';
import basePath from '@salesforce/community/basePath';
import { NavigationMixin } from 'lightning/navigation';
import { reduceErrors } from 'c/ldsUtils';


const EMAIL_MESSAGE = 'Enter your email address';
const SMS_MESSAGE = 'Enter your mobile number';
const EMAIL = 'email';
const SMS = 'mobile';
const SMS_ERROR_MESSAGE = 'Enter a valid 10 digit mobile number';
const EMAIL_ERROR_MESSAGE = 'Enter a valid email address';


export default class Fep_loginandverification extends NavigationMixin(LightningElement) {
    verificationMode;
    verificationModeLabel;
    isVerificationModeEmail = false;
    emailRegex = "[a-zA-Z0-9._%+\\-]+@[a-zA-Z0-9.\\-]+\\.[a-zA-Z]{2,}$";
    mobileRegex = "[0-9]{3}-[0-9]{3}-[0-9]{4}";
    smsErrorMessage = SMS_ERROR_MESSAGE;
    emailErrorMessage = EMAIL_ERROR_MESSAGE;
    selfRegisterUrl;
    showVerificationPage = false;
    encryptedVerificationKey;
    inputValue;
    isLoaded = true;
    errorMessage;
    contactUsLink;
    errorScreenMessage;
    hrefTag;
    redirectMessage;
    get options() {
        return [
            { label: 'Email', value: EMAIL },
            { label: 'Mobile phone/SMS (Text)', value: SMS },
        ];
    }

    smsMessage = 'Message and data rates may apply.'

    connectedCallback() {
        this.verificationMode = EMAIL;
        this.verificationModeLabel = EMAIL_MESSAGE;
        this.isVerificationModeEmail = true;
        this.selfRegisterUrl = basePath + '/SelfRegister';
    }
    handleVeificationModeChange(event) {
        if (event.detail?.value) {
            this.verificationMode = event.detail.value;
            this.verificationModeLabel = event.detail.value == EMAIL ? EMAIL_MESSAGE : SMS_MESSAGE;
            this.isVerificationModeEmail = event.detail.value == EMAIL ? true : false;
            this.errorMessage = null;
        }

    }
    handleInputChange(event) {
        this.inputValue = event.target.value;
    }

    handleMobileChange(event) {
        const target = event.target;
        const input = event.target.value.replace(/\D/g, '').substring(0, 10); // First ten digits of input only
        const zip = input.substring(0, 3);
        const middle = input.substring(3, 6);
        const last = input.substring(6, 10);

        if (input.length > 6) { target.value = `${zip}-${middle}-${last}`; }
        else if (input.length > 3) { target.value = `${zip}-${middle}`; }
        this.inputValue = event.target.value;

    }

    async handleLogin() {
        try {

            let allValid;
            if (this.isVerificationModeEmail) {
                const userInputs = this.template.querySelectorAll('[data-type="user-inputEmail"]');
                console.log(userInputs);
                allValid = [
                    ...userInputs,
                ].reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
                }, true);
            }
            else {
                const userInputs = this.template.querySelectorAll('[data-type="user-inputPhone"]');
                allValid = [
                    ...userInputs,
                ].reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
                }, true);
                this.inputValue = '+1 ' + userInputs[0].value.replaceAll('-', '');
            }
            if (allValid) {
                this.isLoaded = false;
                let data = await handleLoginAndVerification({ inputValue: this.inputValue, verificationMode: this.verificationMode });

                console.log('data' + data);
                if (data) {
                    var loginMetadata = JSON.parse(data);
                    if (loginMetadata.isSuccess) {
                        this.errorMessage = null;
                        this[NavigationMixin.Navigate]({
                            type: 'standard__webPage',
                            attributes: {
                                url: `${basePath}/verifyidentity?identifier=${loginMetadata.identifier}&operation=${loginMetadata.message}&method=${this.verificationMode}&userId=${loginMetadata.userId}`
                            }
                        });
                    }
                    else if (loginMetadata.message !== null) {
                        this.isLoaded = true
                        this.errorMessage = loginMetadata.message;
                        let uri = loginMetadata.identifier=='SelfRegister'&&this.isVerificationModeEmail?`${loginMetadata.identifier}?email=${this.inputValue}`:loginMetadata.identifier;
                        this.contactUsLink = `${basePath}/${uri}`;
                        this.hrefTag = loginMetadata.userId;
                        if(loginMetadata.identifier=='SelfRegister'){
                            this.redirectMessage = true
                            setTimeout(()=>{
                                this[NavigationMixin.Navigate]({
                                    type: 'standard__webPage',
                                    attributes: {
                                        url: `${basePath}/${uri}`
                                    }
                                });
                            },10000)
                        }
                    }



                }
            }
        }
        catch (error) {
            this.isLoaded = true;
            this.errorMessage = reduceErrors(error)[0];
            if(this.errorMessage.includes('This user doesn\'t have access to this verification method.')){
                this.errorMessage = 'Your mobile phone is not verified with us. Please login with email and verify you mobile phone.'
            }

            console.error(reduceErrors(error)[0]);
        }
    }

    handleAlert() {
        this.errorMessage = null;
    }
}