public with sharing class ContactPhotoController {

    @AuraEnabled
    public static void updateContactPhoto(Id documentId) {
        // TODO:  Build some error handling

        // Query the ContentDocument record
        //ContentDocument contentDocument = [SELECT Id, Title FROM ContentDocument WHERE Id = :documentId LIMIT 1];
    
        // Update the Title field
        //contentDocument.Title = 'ContactPhoto';
        //update contentDocument;

        // Query the ContentDocument record
        List<ContentDocument> contentDocuments = [SELECT Id, Title FROM ContentDocument WHERE Id = :documentId LIMIT 1];
    
        // Check if the query returned a record
        if (contentDocuments.isEmpty()) {
            // Throw a custom exception if no record is found
            throw new AuraHandledException('No ContentDocument found with the provided Id.');
        }
    
        // Update the Title field
        ContentDocument contentDocument = contentDocuments[0];
        contentDocument.Title = 'ContactPhoto';
        update contentDocument;
    }

    @AuraEnabled(cacheable=true)
    public static String getContactPhoto(Id contactId) {
     //   List<ContentDocumentLink> links = [SELECT ContentDocumentId 
     //                                    FROM ContentDocumentLink 
     //                                   WHERE LinkedEntityId = :contactId
     //                                    ORDER BY SystemModstamp DESC 
     //                                    LIMIT 1];
     
        // Retrieve only if the Title is 'ContactPhoto'
        List<ContentDocumentLink> links = [SELECT ContentDocumentId 
                                            FROM ContentDocumentLink 
                                            WHERE LinkedEntityId = :contactId 
                                            AND ContentDocument.Title = 'ContactPhoto'
                                            LIMIT 1];

        if (!links.isEmpty()) {
            List<ContentVersion> versions = [SELECT VersionDataUrl 
                                           FROM ContentVersion 
                                           WHERE ContentDocumentId = :links[0].ContentDocumentId 
                                           AND IsLatest = TRUE 
                                           LIMIT 1];
            return versions.isEmpty() ? null : versions[0].VersionDataUrl;
        }
        return null;
    }

    @AuraEnabled
    public static void deleteContactPhoto(Id contactId) {
        List<ContentDocumentLink> links = [SELECT ContentDocumentId 
                                         FROM ContentDocumentLink 
                                         WHERE LinkedEntityId = :contactId
                                         AND ContentDocument.Title = 'ContactPhoto'
                                         LIMIT 1];
        
        if (!links.isEmpty()) {
            Set<Id> documentIds = new Set<Id>();
            for (ContentDocumentLink link : links) {
                documentIds.add(link.ContentDocumentId);
            }
            delete [SELECT Id FROM ContentDocument WHERE Id IN :documentIds];
        }
    }

    @AuraEnabled
    public static void uploadContactPhoto(Id contactId, String fileName, String base64Data) {
        deleteContactPhoto(contactId); // Delete existing photos first
        
        ContentVersion cv = new ContentVersion(
            VersionData = EncodingUtil.base64Decode(base64Data),
            Title = fileName,
            PathOnClient = fileName
        );
        insert cv;

        cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = contactId,
            ShareType = 'V'
        );
        insert cdl;
    }
}