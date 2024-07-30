public with sharing class LLMComponentCtrl {
    @AuraEnabled(cacheable=false)
    public static String generate(String prompt, String model) {        
        aiplatform.ModelsAPI.createGenerations_Request request = new aiplatform.ModelsAPI.createGenerations_Request();
        // TODO: make model configurable!
        request.modelName = model;    
        request.body = new aiplatform.ModelsAPI_GenerationRequest();
        request.body.prompt = prompt;

        try {
            aiplatform.ModelsAPI modelsAPI = new aiplatform.ModelsAPI();
            aiplatform.ModelsAPI.createGenerations_Response response = modelsAPI.createGenerations(request);
            return response.Code200.generation.generatedText;
        } catch(aiplatform.ModelsAPI.createGenerations_ResponseException e) {
            System.debug('Response code: ' + e.responseCode);
            System.debug('The following exception occurred: ' + e);
            throw e;
        }
    }
}