import { LightningElement, api } from 'lwc';
import LightningAlert from 'lightning/alert';

import summarize from "@salesforce/apex/SummarizeFieldsCtrl.summarize";


export default class SummarizeFields extends LightningElement {
    @api prompt_template;
    output = "";

    @api title;
    @api results;

    get stringResults() {
        if(this.results) {
            console.log("returning json")
            return JSON.stringify(this.results)
        }
        else {
            console.log("returning nothing.")
            return "(no results)"
        }        
    }

    async run() {
        // TODO make promptTemplate dynamic
        let result = await summarize( {promptTemplate: prompt_template, data: JSON.stringify(this.results)} );
        console.log(result);
        this.output = result; //"Ran at " + new Date().toISOString();
    }

    async showData() {
        let _ = await LightningAlert.open({
            message: JSON.stringify(this.results),            
            label: 'Data',
            theme: 'inverse'
        })
    }
}