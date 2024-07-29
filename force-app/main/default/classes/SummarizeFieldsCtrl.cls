public with sharing class SummarizeFieldsCtrl {
    @AuraEnabled(cacheable=false)
    public static String summarize(String promptTemplate, String data) {
        ConnectApi.EinsteinPromptTemplateGenerationsInput promptGenerationsInput = 
            new ConnectApi.EinsteinPromptTemplateGenerationsInput();
        promptGenerationsInput.isPreview = false;

        Map<String,ConnectApi.WrappedValue> valueMap = new Map<String,ConnectApi.WrappedValue>();
        ConnectApi.WrappedValue wrappedData = new ConnectApi.WrappedValue();
        wrappedData.value = data;
        valueMap.put('Input:data', wrappedData);
        promptGenerationsInput.inputParams = valueMap;

        promptGenerationsInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
        promptGenerationsInput.additionalConfig.applicationName = 'PromptTemplateGenerationsInvocable';

        // 0hfWz000000EkarIAC
        ConnectApi.EinsteinPromptTemplateGenerationsRepresentation generationsOutput = 
            ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate('Summarize_Comments', promptGenerationsInput); 
      
        System.debug(generationsOutput);

        if(generationsOutput.generations.size() > 0) {
            return generationsOutput.generations[0].text;    
        }
        else {
            return 'Ooops';
        }
    }
}