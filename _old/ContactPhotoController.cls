public with sharing class ContactPhotoController {
    @AuraEnabled
    public static String getContactPhoto(Id contactId) {
        List<ContentDocumentLink> links = [SELECT ContentDocumentId 
                                         FROM ContentDocumentLink 
                                         WHERE LinkedEntityId = :contactId
                                         ORDER BY SystemModstamp DESC 
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
                                         WHERE LinkedEntityId = :contactId];
        
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
