@isTest
public with sharing class LLMComponentCtrlTest {
    public class ModelAPIMockImpl implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {            
            if(req.getEndpoint().contains('does_not_exist')) {
                HttpResponse res = new HttpResponse();
                res.setStatusCode(500);
                return res;
            }

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(
                '{\n' + 
                '   "id": "chatcmpl-8diKGsPooFDwwhbJxmibpUc7437at",\n' + 
                '   "generation": {\n' +
                '       "id": "4399c4ea-89d4-44ca-ae8d-cf5926b41bc4",\n' +
                '       "generatedText": "The answer is 42.",\n' +
                '       "contentQuality": {\n' + 
                '           "scanToxicity": {\n' +
                '               "isDetected": false,\n' +
                '               "categories": [\n' +
                '                   {\n' +
                '                       "categoryName": "profanity",\n' +
                '                   "score": 0\n' +
                '                  }\n' +
                '               ]\n' +
                '           }\n' +
                '       },\n' +
                '       "parameters": {\n' +
                '           "finish_reason": "stop",\n' +
                '           "index": 0,\n' +
                '           "logprobs": null\n' +
                '       },\n' +
                '       "text": ""\n' +
                '   },\n' +
                '   "prompt": "Invent 3 fun names for donuts",\n' +
                '   "parameters": {\n' +
                '       "model": "gpt-3.5-turbo-0125",\n' +
                '       "object": "chat.completion",\n' +
                '       "usage": {\n' +
                '           "prompt_tokens": 14,\n' +
                '           "completion_tokens": 15,\n' +
                '           "total_tokens": 29\n' +
                '       }\n' +
                '   }\n' +
                '}\n'
            );
            res.setStatusCode(200);
            //Assert.fail('mock handler is not invoked for some reason');            
            return res;
        }
    }

    @isTest
    public static void testGenerate() {                
        Test.setMock(HttpCalloutMock.class, new ModelAPIMockImpl());
        String prompt = 'What is the meaning of life, the universe, and everything?';
        String model = 'sfdc_ai__DefaultOpenAIGPT4_32k';
        String result = LLMComponentCtrl.generate(prompt, model);            
        Assert.isTrue( result.contains('42'), 'LLM generated answer without exceptions, but the answer is weird...');
    }

    @isTest
    public static void testGenerateException() {
        Test.setMock(HttpCalloutMock.class, new ModelAPIMockImpl());
        String prompt = 'What is the meaning of life, the universe, and everything?';
        String model = 'does_not_exist';
        try {
            String result = LLMComponentCtrl.generate(prompt, model);
        }
        catch(Exception e) {
            return;
        }
        Assert.fail('generate() should have raised an exception since the model does not exist');
    }   

    @isTest
    public static void testRunPromptException(){
        try {
            LLMComponentCtrl.runPrompt(null, 'none');
        }
        catch(Exception e) {
            return;
        }
        Assert.fail('runPrompt() should have raised an exception since the template does not exist');        
    }
    
}