import { LightningElement, api, wire } from 'lwc';
//import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { RefreshEvent } from 'lightning/refresh';
import LightningConfirm from 'lightning/confirm';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getContactPhoto from '@salesforce/apex/ContactPhotoController.getContactPhoto';
import updateContactPhoto from '@salesforce/apex/ContactPhotoController.updateContactPhoto';
import deleteContactPhoto from '@salesforce/apex/ContactPhotoController.deleteContactPhoto';
//import uploadContactPhoto from '@salesforce/apex/ContactPhotoController.uploadContactPhoto';

const FIELDS = ['Contact.Name'];

export default class ContactPhotoUploader extends LightningElement {
    @api recordId; // Contact ID
    photoUrl;
    selectedFile;
    contact;
    @api contactId;
    wiredPhotoResponse; // To store the wired response for refresh

    // LWC properties
    @api cmpTitle;
    @api photoHeight;
    @api photoWidth;
    @api defaultPhoto;

    get acceptedFormats() {
        return ['.jpg', '.png', '.jpeg'];
    }

    @wire(getContactPhoto, { contactId: '$recordId' })
    wiredPhoto(response) {
        this.wiredPhotoResponse = response; // Store the response for refresh
    
        if (response.data) {
            this.photoUrl = response.data;
        } else if (response.error) {
            console.error('Error fetching photo:', response.error);
            this.showToast('Failure', response.error, 'error');
            
        }
    }

    handleUploadFinished(event) {
        
        // update the title of the file uploaded to ContactPhoto
        const uploadedFiles = event.detail.files[0];
        var documentId  = uploadedFiles.documentId;
        //alert('No. of files uploaded : ' + uploadedFiles.length);
        //alert('ID: ' + documentId);


        // Change the Title of the file to "ContactPhoto"
        try {
            updateContactPhoto({ documentId : documentId });
            this.showToast('Success', 'Contact Photo updated successfully', 'success');

            console.log("uploaded")
        } catch (error) {
            console.error(error);
            console.log("upload/update failed");
        }

        this.dispatchEvent(new RefreshEvent());
        // Refresh the wired data
        refreshApex(this.wiredPhotoResponse);
    }    

    async performDeletePhoto() {
        console.log("peform delete...1");
        try {
            deleteContactPhoto({ contactId: this.recordId });
            this.photoUrl = null;

            console.log("delete success");

            //success message
            this.showToast('Success', 'Contact Photo deleted successfully', 'success');
   
        } catch (error) {
            console.error(error);
            console.log("delete failed");

            //error message
            this.showToast('Error', 'Unable to delete Contact Photo', 'error');

        }  

        
        this.dispatchEvent(new RefreshEvent());
        // Refresh the wired data
        refreshApex(this.wiredPhotoResponse);
    }

    async handleDeletePhoto() {

        console.log("Handle delete...");
        const result = await LightningConfirm.open({
            message: 'Are you sure you want to delete the Contact Photo?',
            variant: 'header',
            label: 'Confirm Photo Deletion',
            theme: 'warning',
        });
        console.log(result);

        if (result) {
            this.performDeletePhoto();
        }

    } 
    
    loadPhoto() {
        // Refresh photo URL with timestamp to bypass cache
        this.photoUrl = this.photoUrl ? `${this.photoUrl}?${Date.now()}` : null;
    }

    /** 
     * Reusable function to show toast notification
     * @param {string} title - The title of the toast
     * @param {string} message - The message of the toast
     * @param {string} variant - The variant of the toast (e.g., 'success', 'error')
     */
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }   

 /*   @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredContact({ error, data }) {
        if (data) {
            this.contact = data;
            this.loadPhoto();
        } else if (error) {
            console.error(error);
        }
    } */


  /*  handleFileSelected(event) {
        const file = event.target.files[0];
        if (file) {
            this.selectedFile = file;
            this.uploadPhoto();
            const reader = new FileReader();
            reader.onload = () => {
                this.photoUrl = reader.result; // Show preview before upload
            };
            reader.readAsDataURL(file);
        }
    } */
    /*handleFileSelected(event) {
        const file = event.target.files[0];
        if (file) {
            this.selectedFile = file;
            this.uploadPhoto();
        }
    }*/

  /*  async uploadPhoto() {
        try {
            const base64 = await this.readFile(this.selectedFile);
            await uploadContactPhoto({
                contactId: this.recordId,
                fileName: this.selectedFile.name,
                base64Data: base64.split(',')[1]
            });
            this.loadPhoto();
        } catch (error) {
            console.error(error);
        }
    }*/



  /*  readFile(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = () => resolve(reader.result);
            reader.onerror = () => reject(reader.error);
            reader.readAsDataURL(file);
        });
    } */


}