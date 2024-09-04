import { LightningElement,wire } from "lwc";
import { NavigationMixin } from 'lightning/navigation';
import isGuest from "@salesforce/user/isGuest";
import basePath from "@salesforce/community/basePath";
import Id from "@salesforce/user/Id";
import getUserDetails from '@salesforce/apex/FEP_LogoutButtonController.getUserDetails';
import { reduceErrors } from 'c/ldsUtils';
export default class Logout extends NavigationMixin(LightningElement) {

    get isGuest() {
        return isGuest;
    }

    userId= Id;

    userName='';
    imgUrl='';
    isVerified = true;

    @wire(getUserDetails,{userId:'$userId'})
    getWebinarList(result) {
  
        console.log(result)
        if(result.data){
            const userDetails = JSON.parse(result.data);
            this.userName = userDetails.fullName;
            this.imgUrl= userDetails.logoUrl;
            this.isVerified = userDetails.isverified?false:true;
            console.log(result.data);
        }
    }

    handleLogout() {
        try {
            const sitePrefix = basePath.replace(/\/s$/i, "");
            let url = sitePrefix + '/secur/logout.jsp';
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__webPage',
                attributes: {
                    url: `${url}`
                }
            }).then(url => {
                window.open(url, "_self")
            });
        } catch (error) {
            console.error(error.message);
        }
    }

    async handleRegisterMobile(){
        try{
          /*  let data = await registerMobile();
            if(data){
                let loginMetadata = JSON.parse(data);
                console.log(JSON.stringify(data));
                if(loginMetadata.identifier?.includes('This user is already')){
                        await LightningAlert.open({
                            message: 'Your mobile phone is already verified with us.',
                            theme: 'error', // a red theme intended for error states
                            label: 'Already Verified', // this is the header text
                        });
                }*/
              // else{
                this[NavigationMixin.GenerateUrl]({
                    type: 'standard__webPage',
                    attributes: {
                        url: `${basePath}/verifymobile`
                    }
                }).then(url => {
                    window.open(url, "_self")
                });
           // }
          //  }
        }catch(error){
            console.error(reduceErrors(error))
        }
    }
}