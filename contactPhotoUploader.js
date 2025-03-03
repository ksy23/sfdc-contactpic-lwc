// contactPhotoUploader.js
import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getContactPhoto from '@salesforce/apex/ContactPhotoController.getContactPhoto';
import deleteContactPhoto from '@salesforce/apex/ContactPhotoController.deleteContactPhoto';
import uploadContactPhoto from '@salesforce/apex/ContactPhotoController.uploadContactPhoto';

const FIELDS = ['Contact.Name'];

export default class ContactPhotoUploader extends LightningElement {
    @api recordId; // Contact ID
    photoUrl;
    selectedFile;
    contact;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredContact({ error, data }) {
        if (data) {
            this.contact = data;
            this.loadPhoto();
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getContactPhoto, { contactId: '$recordId' })
    wiredPhoto({ error, data }) {
        if (data) {
            this.photoUrl = data;
        } else if (error) {
            console.error(error);
        }
    }

    handleFileSelected(event) {
        const file = event.target.files[0];
        if (file) {
            this.selectedFile = file;
            this.uploadPhoto();
        }
    }

    async uploadPhoto() {
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
    }

    async handleDeletePhoto() {
        try {
            await deleteContactPhoto({ contactId: this.recordId });
            this.photoUrl = null;
        } catch (error) {
            console.error(error);
        }
    }

    readFile(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = () => resolve(reader.result);
            reader.onerror = () => reject(reader.error);
            reader.readAsDataURL(file);
        });
    }

    loadPhoto() {
        // Refresh photo URL with timestamp to bypass cache
        this.photoUrl = this.photoUrl ? `${this.photoUrl}?${Date.now()}` : null;
    }
}
