@isTest
public class QuestionaireGenCtrlExtTest {
    @isTest
    static void fullTest() {
        Matter__c matterRecord =  new Matter__c(
            External_Id__c = 'EXT-001',
            Display_Name__c = 'Test Matter 1',
            Status__c = 'New',
            Description__c = 'Description here 2',
            PDFQuestionnaireJSON__c = '{"title": "Example", "clientName": "Example", "sections": [{ "sectionTitle": "title", "options": { "showLabels": "true" }, "fields": [{ "label": "labelValue", "value": "value" }, { "label": "labelValue", "value": "value" }, { "label": "labelValue", "value": "value" } ] } ] }'
        );
        insert matterRecord;
        String title;
        String clientName;
        Test.StartTest();

        //NOTE:- Create Issue__c  object in your test class
        ApexPages.currentPage()
            .getParameters()
            .put('lookupVal', String.valueOf(matterRecord.Id));

        ApexPages.StandardController sc = new ApexPages.StandardController(
            matterRecord
        );
        QuestionaireGenCtrlExt qgce = new QuestionaireGenCtrlExt(sc);
        title = qgce.getTitle();
        clientName = qgce.getClientName();

        Test.StopTest();

        System.assertEquals(title, 'Example');
        System.assertEquals(clientName, 'Example');
    }
}