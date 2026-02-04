public with sharing class QuestionaireGenCtrlExt {
    private Id recordId;

    public Id matterId { get; set; }  // Explicit public property for Id
    public String dynamicMessage { get; set; }
    private Map<String, Object> JSONMap;
    public List<Section> sections { get; set; }
    public Boolean toogleJSONRender { get; set; }

    public QuestionaireGenCtrlExt(ApexPages.StandardController stdController) {
        Matter__c matterObject = (Matter__c) stdController.getRecord();
        this.recordId = matterObject.id;
        this.matterId = matterObject.id;
        matterObject = [
            SELECT ID, PDFQuestionnaireJSON__c
            FROM Matter__c
            WHERE ID = :this.recordId
        ];
        
        if (String.isBlank(matterObject.PDFQuestionnaireJSON__c)) {
            toogleJSONRender = false;
            dynamicMessage = 'No PDF Questionnaire Data Found.';
        } else {
            toogleJSONRender = true;
            //Clean up the JSON String to remove Next Line issue
            String jsonString;
            try{
                jsonString = sanitizedJson(
                    matterObject.PDFQuestionnaireJSON__c
                );
            }
            catch(Exception e){
                toogleJSONRender = false;
                dynamicMessage = 'Error processing JSON data: ' + e.getMessage();
                return;
            }
            
            try{
                this.JSONMap = (Map<String, Object>) JSON.deserializeUntyped(
                    jsonString
                );
            }
            catch(Exception e){
                toogleJSONRender = false;
                dynamicMessage = 'Error parsing JSON data: ' + e.getMessage();
                return;
            }
            List<Object> sectionList = (List<Object>) this.JSONMap.get(
                'sections'
            );
            sections = new List<Section>();
            for (Object o : sectionList) {
                Section sec = new Section();
                Map<String, Object> section = (Map<String, Object>) o;
                sec.sectionTitle = (String) section.get('sectionTitle');
                Map<String, Object> options = (Map<String, Object>) section.get(
                    'options'
                );
                String labels = (String) options.get('showLabels');
                sec.showLabels = labels.equals('true') ? true : false;
                List<Object> fieldList = (List<Object>) section.get('fields');
                sec.fields = new List<Field>();
                for (Object p : fieldList) {
                    Map<String, Object> f = (Map<String, Object>) p;
                    Field fieldWithLabel = new Field();
                    fieldWithLabel.label = (String) f.get('label');
                    fieldWithLabel.value = (String) f.get('value');
                    sec.fields.add(fieldWithLabel);
                }
                this.sections.add(sec);
            }
        }
    }

    /**
     * Cleans up a JSON string by trimming whitespace and replacing newline characters with spaces.
     * This method is designed to sanitize input JSON strings that may contain extraneous whitespace
     * or newline characters that could interfere with JSON parsing processes. This makes the JSON 
     * string safe for parsing and processing in JSON parsers.
     * @param input The JSON string to be sanitized. Can be null, in which case the function returns null.
     * @return A sanitized JSON string with trimmed whitespace and no newline characters. Returns null if the input is null.
     */
    public String sanitizedJson(String input) {
        if (input == null) 
            return null;

        return input.trim().replaceAll('\r\n|\n|\r', '');
    }

    public String getTitle() {
        return (String) this.JSONMap.get('title');
    }

    public String getClientName() {
        return (String) this.JSONMap.get('clientName');
    }

    public class Field {
        public String label { get; set; }
        public String value { get; set; }
    }

    public class Section {
        public List<Field> fields { get; set; }
        public Boolean showLabels { get; set; }
        public String sectionTitle { get; set; }
    }
}