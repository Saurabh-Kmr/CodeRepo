/*------------------------------------------------------------
Author:        Mohit Jain
Company:       Salesforce
Description:   Controller Class to show list of Scheduled, Cancelled, Completed Appointments to client
Inputs:                      
Test Class:    
History
14/03/2024      Mohit Jain    New Class Created for PR972315-14
------------------------------------------------------------*/


public  without sharing class FEP_AppointmentList {
    


    @AuraEnabled
    public static List<appointmentsList> getAllAppointmentsForContact(String contactId){
        try {
            List<appointmentsList> formattedAppointmentList = new List<appointmentsList>();
            List<ServiceAppointment> listOfRelatedAppointment = new List<ServiceAppointment>([Select Id,Status,AppointmentNumber,SchedStartTime,FEP_AppointmentDateTimeText__c,(Select ServiceResourceId,ServiceResource.isActive,ServiceResource.Name from ServiceResources where ServiceResource.isActive= true AND IsRequiredResource =true order by CreatedDate ASC) from ServiceAppointment where ContactId=:ContactId order by SchedStartTime DESC]);
            formattedAppointmentList = mapallAppts(listOfRelatedAppointment); 
            
            return formattedAppointmentList;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

     /*------------------------------------------------------------
    Author:        Mohit Jain
    Company:       Salesforce
    Description:   Function returns List of Appointments
    Inputs:        userRecordId - Logged in user record id
                   
    Returns:       String- Serialized data of appointments
                
    History
   14/03/2024      Mohit Jain    New Class Function for PR972315-14
    ------------------------------------------------------------*/
    @AuraEnabled
    public static List<appointmentsList> getAppointmentList(String userRecordId){

        System.debug(userRecordId);

        User loggedInUser = [Select Id,Name,ContactId,TimeZoneSidKey from User where id = :userRecordId Limit 1];

        System.debug(loggedInUser.ContactId);
        List<appointmentsList> formattedAppointmentList = new List<appointmentsList>();

        // Check for logged-in user have related contact or not
        if(!String.isEmpty(loggedInUser.ContactId) ){

            List<ServiceAppointment> listOfRelatedAppointment = getRelatedAppointments(loggedInUser.ContactId);
        
            formattedAppointmentList = mapallAppts(listOfRelatedAppointment); 

            return formattedAppointmentList;

        }

      return new List<appointmentsList>();
        

    }


    public static List<appointmentsList> mapallAppts(List<ServiceAppointment> sppList){

        List<appointmentsList> formattedAppointmentList = new List<appointmentsList>();

        for(ServiceAppointment sa : sppList){
            System.debug('sa.ServiceResources ::'+sa.ServiceResources);
            // Check for Appointment have the Active Service Resource or not
            if(! sa.ServiceResources.isEmpty()){
                appointmentsList singleAppointment = new appointmentsList();

                // String formattedString = sa.SchedStartTime.format('yyyy-MM-dd HH:mm:ss a','GMT');
                // DateTime gmtFormatTime =  Datetime.valueOf(formattedString);
                // singleAppointment.date_time = gmtFormatTime.format('MM/dd/yyyy hh:mm a z',loggedInUser.TimeZoneSidKey);
                singleAppointment.date_time = sa.FEP_AppointmentDateTimeText__c;
                singleAppointment.coach_name = sa.ServiceResources[0].ServiceResource.Name;
                singleAppointment.coach_id = sa.ServiceResources[0].ServiceResource.Id;
                singleAppointment.appointment_name = sa.AppointmentNumber;
                singleAppointment.appointment_id = sa.Id;
                singleAppointment.status = sa.Status;
                singleAppointment.showAction = true;

                Date myDate = sa.SchedStartTime.dateGMT();
                if( singleAppointment.status == 'Canceled' || singleAppointment.status == 'Completed' || Date.today() > myDate){

                    singleAppointment.showAction = false;
                }

                formattedAppointmentList.add(singleAppointment);

            }
            
        }
        return formattedAppointmentList;
    }





     /*------------------------------------------------------------
    Author:        Mohit Jain
    Company:       Salesforce
    Description:   Function returns List of Appointments
    Inputs:        contactId - Related contact of logged in user
                   
    Returns:       List of related appointments of the contact
                
    History
   14/03/2024      Mohit Jain    New Class Function for PR972315-14
    ------------------------------------------------------------*/

    @AuraEnabled
    public static List<ServiceAppointment> getRelatedAppointments(String ContactId){

        return([Select Id,Status,AppointmentNumber,SchedStartTime,FEP_AppointmentDateTimeText__c,(Select ServiceResourceId,ServiceResource.isActive,ServiceResource.Name from ServiceResources WHERE IsRequiredResource =true order by CreatedDate ASC) from ServiceAppointment where ContactId=:ContactId order by SchedStartTime DESC ]);
    }


    /*------------------------------------------------------------
    Author:        Mohit Jain
    Company:       Salesforce
    Description:   Function returns List of Appointments
    Inputs:        contactId - Related contact of logged in user
                   
    Returns:       List of related appointments of the contact
                
    History
   14/03/2024      Mohit Jain    New Class Function for PR972315-14
    ------------------------------------------------------------*/

    @AuraEnabled
    public static String cancelAppointment(String appointmentId, String reason){
        String message='';
        try{
            ServiceAppointment spObj = new ServiceAppointment();
            spObj.Id = appointmentId;
            spObj.Status = 'Canceled';
            spObj.CancellationReason = reason;
            update spObj;
            
            message = 'success';
            return message;
        }catch(Exception ex){
            message = 'failed';
            return message;
        } 
    }

    @AuraEnabled
    public static ServiceAppointment getAppointmentDetails(String appointmentId){ 
        try{
            List<ServiceAppointment> spList = new List<ServiceAppointment>([Select Id,Assigned_Coach__c,Assigned_Coach__r.Name,FEP_ScheduledStartFormula__c,AppointmentNumber,FEP_AppointmentDateTimeText__c from ServiceAppointment where Id=:appointmentId]);
             
            return spList[0];
        }catch(Exception ex){
            throw new AuraHandledException('An error occurred. Please try again.');
        } 
    }


    /*------------------------------------------------------------
        Author:        Mohit Jain
        Company:       Salesforce
        Description:   Wrapper class for appointment list
        Inputs:                      
        Test Class:    
        History
        14/03/2024      Mohit Jain    New Class Created for PR972315-14
    ------------------------------------------------------------*/

    public class appointmentsList{


        @AuraEnabled
        public String date_time;

        @AuraEnabled
        public string coach_name;

        @AuraEnabled
        public string coach_id;

        @AuraEnabled
        public string appointment_name;

        @AuraEnabled
        public string appointment_id;

        @AuraEnabled
        public string status;

        @AuraEnabled
        public boolean showAction;
    }
}