import { LightningElement, api } from 'lwc';
import LightningAlert from 'lightning/alert';
import generate from "@salesforce/apex/LLMComponentCtrl.generate";

export default class AccountSummarizer extends LightningElement {
    @api title;
    @api results;
    @api setSelection;
    @api selectMode;
    
    
    @api heading;
    @api model;
    @api twoColumns;

    _selection;
    
    containerHeight;
    headingHeight;
    recordIdentifier = "Id";

    @api
    get selection(){
      return this._selection;
    }
    
    set selection(val){
      
      if(val.length>0){
        this._selection = val;
        this.run(this._selection[0]);
        console.log("setter",JSON.stringify(val, null, 2));
      }
    }
    
    @api defaultPrompt;
    prompt;
    output = "";
    spinner = false;
    
    connectedCallback() {
        this.prompt = this.defaultPrompt;
    }

    isFirstLoad = false;
    // eslint-disable-next-line no-unused-vars
    @api stateChangedCallback(_prevState, _newState) {
        
    }

    // ----------------------------------------------------------------
    // Layout and data getters
    // ----------------------------------------------------------------

    get promptClasses() {        
        return "slds-col slds-p-around_medium " + (this.twoColumns ? "slds-size_1-of-3" : "slds-size_1-of-1");
    }

    get promptStyle() {
        // TODO: check for twoColumns, see if we can remove the errors/warning in HTML related to style attribute
        if(this.twoColumns) {
            return `height: calc(100% - ${this.headingHeight}px)`;
        }
        
        let h = (this.containerHeight - this.headingHeight) * 0.3;
        return `height: ${h}px`;                
    }

    get textareaStyle() {
        const subtractor = 40;
        const multiplicator = this.twoColumns ? 1.0 : 0.3;        
        const h = (this.containerHeight - this.headingHeight) * multiplicator - subtractor;
        return `--slds-c-textarea-sizing-min-height: ${h}px`;
    }

    get outputClasses() {
        return "slds-col slds-p-around_medium " + (this.twoColumns ? "slds-size_2-of-3" : "slds-size_1-of-1");
    }

    get outputStyle() {
        if(this.twoColumns) {
            return `height: calc(100% - ${this.headingHeight}px)`;
        }        
        let h = (this.containerHeight - this.headingHeight) * 0.7
        return `height: ${h}px`;                    
    }

    get outputParagraphs() {
        return this.output ? this.output.split("\n") : [];        
    }

    renderedCallback() {
        window.addEventListener('resize', () => { this.handleResize(); });
        this.handleResize();
    }
    
    handleResize() {
        this.headingHeight = this.refs.heading ? this.refs.heading.offsetHeight : 0;   
        this.containerHeight = this.refs.main ? this.refs.main.offsetHeight : 0;
    }    

    // ----------------------------------------------------------------
    // Event handlers
    // ----------------------------------------------------------------

    generatePrompt(accontDetails) {
        return "Answer the following question based on the data provided " +
            "after the question in JSON format:\n" +
            this.prompt + "\n"+ JSON.stringify(accontDetails, null, 4)
    }    

    async run(accontDetails) {
        console.log("selectMode = " + this.selectMode);
        this.spinner = true;
        this.output = "";
        this.selection_changed = false;
        console.log("summarizer", this.generatePrompt(accontDetails));
        try { 
          let previousText = this.getFromCache(accontDetails[this.recordIdentifier])
            if(!previousText){
              let result = await generate( { prompt: this.generatePrompt(accontDetails), model: this.model } );
              this.cacheResults(accontDetails[this.recordIdentifier], result);
              this.output = result;
            }   
            else{
              this.output = previousText;
            }
            
            this.error = undefined;
        }
        catch(e) {
            console.log("Exception");
            console.log(e);
            this.output = undefined;
            this.error = e.body.exceptionType + ": " + e.body.message;
        }
        finally {
            this.spinner = false;            
        }
    }

    cacheResults(id, data){
      localStorage.setItem(id, data);
    }

    getFromCache(id){
      return localStorage.getItem(id)
    }

   
}