import { LightningElement} from 'lwc';
import verifyMobile from '@salesforce/apex/Fep_loginandverification.verifyMobile';
import registerMobile from '@salesforce/apex/Fep_loginandverification.registerMobile';
import {  NavigationMixin } from 'lightning/navigation';
import basePath from '@salesforce/community/basePath';
import { reduceErrors } from 'c/ldsUtils';

export default class Fep_verifyMobile extends NavigationMixin(LightningElement) {
    code;
    identifier;
    method;
    operation;
    userId;
    isLoaded = true;
    errorMessage;
    showRegisterMobile;
    successMessage;

    

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
            if(!this.code){
               this.errorMessage= 'Please provide the verification code.';
            }
            else{
            this.isLoaded = false;
                let data = await verifyMobile({  code: this.code });
                this.isLoaded = true;
                if (data) {
                    if(data==='Token not valid'){
                        this.errorMessage = 'Please enter valid verfication code.';
                    }      
                }
                else{
                    this.errorMessage=null;
                    this.successMessage = 'Mobile phone verified successfully.';
                   setTimeout(
                    this[NavigationMixin.GenerateUrl]({
                        type: 'standard__webPage',
                        attributes: {
                            url: `${basePath}/`
                        }
                    }).then(url => {
                        window.open(url, "_self")
                    }),10000);
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
            let data = await registerMobile();;
            if (data) {
                if(data){
                    let loginMetadata = JSON.parse(data);
                    if(loginMetadata.identifier?.includes('This user is already')){
                            await LightningAlert.open({
                                message: 'Your mobile phone is already verified with us.',
                                theme: 'error', // a red theme intended for error states
                                label: 'Already Verified', // this is the header text
                            });
                    }
                }
            }

        } catch (error) {
            this.data = null;
            this.errorMessage = reduceErrors(error)[0];
            console.error(reduceErrors(error)[0]);
        }


    }

    handleSkip(){
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: `${basePath}/`
            }
        }).then(url => {
            window.open(url, "_self")
        });
    }

    async handleSendCode(){
        try{
            this.showRegisterMobile =true;
            let data = await registerMobile();
            if(data){
                let loginMetadata = JSON.parse(data);
                if(loginMetadata.identifier?.includes('This user is already')){
                        await LightningAlert.open({
                            message: 'Your mobile phone is already verified with us.',
                            theme: 'error', // a red theme intended for error states
                            label: 'Already Verified', // this is the header text
                        });
                }
            }
        }catch(error){
            console.error(reduceErrors(error))
        }
    }

}