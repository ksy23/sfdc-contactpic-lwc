/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class contactPhotoControllerTest {

    @testSetup
    static void setupTestData() {
        // Create a test Contact
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact');
        insert testContact;

        // Create a test ContentDocument and ContentVersion
        ContentVersion contentVersion = new ContentVersion(
            Title = 'TestDocument',
            PathOnClient = 'TestDocument.jpg',
            VersionData = Blob.valueOf('Test data')
        );
        insert contentVersion;

        // Query the ContentDocumentId
        ContentVersion insertedVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id];
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
            ContentDocumentId = insertedVersion.ContentDocumentId,
            LinkedEntityId = testContact.Id,
            ShareType = 'V'
        );
        insert contentDocumentLink;
    }

    @isTest
    static void testUpdateContactPhoto() {
        // Query the ContentDocument
        ContentDocument contentDocument = [SELECT Id FROM ContentDocument LIMIT 1];
        
        // Call the method
        Test.startTest();
        ContactPhotoController.updateContactPhoto(contentDocument.Id);
        Test.stopTest();

        // Verify the Title was updated
        ContentDocument updatedDocument = [SELECT Title FROM ContentDocument WHERE Id = :contentDocument.Id];
        System.assertEquals('ContactPhoto', updatedDocument.Title, 'The ContentDocument title should be updated.');
    }

    @isTest
    static void testGetContactPhoto() {
        // Query the Contact
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];

        // Call the method
        Test.startTest();
        String photoUrl = ContactPhotoController.getContactPhoto(testContact.Id);
        Test.stopTest();

        // Verify the URL is returned
        System.assertNotEquals(null, photoUrl, 'The photo URL should not be null.');
    }

    @isTest
    static void testDeleteContactPhoto() {
        // Query the Contact
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];

        // Call the method
        Test.startTest();
        ContactPhotoController.deleteContactPhoto(testContact.Id);
        Test.stopTest();

        // Verify the ContentDocumentLink is deleted
        List<ContentDocumentLink> links = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :testContact.Id];
        System.assertEquals(0, links.size(), 'All ContentDocumentLinks should be deleted.');
    }

    @isTest
    static void testUploadContactPhoto() {
        // Query the Contact
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];

        // Call the method
        Test.startTest();
        ContactPhotoController.uploadContactPhoto(testContact.Id, 'NewPhoto.jpg', EncodingUtil.base64Encode(Blob.valueOf('New photo data')));
        Test.stopTest();

        // Verify the ContentDocumentLink is created
        List<ContentDocumentLink> links = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :testContact.Id];
        System.assertEquals(1, links.size(), 'A new ContentDocumentLink should be created.');
    }
}