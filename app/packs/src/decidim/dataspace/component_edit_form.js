document.addEventListener("DOMContentLoaded", function(){
    const integrationCheck = document.querySelector('input#component_settings_add_integration')
    const urlDiv = document.querySelector("div.integration_url_container")
    const localeDiv = document.querySelector("div.preferred_locale_container")
    const inputUrl = document.querySelector("input[name='component[settings][integration_url]']")
    inputUrl.setAttribute("placeholder", "https://platform.com, https://example.com")

    if(integrationCheck){
        if(integrationCheck.checked){
            urlDiv.style.display = "block";
            localeDiv.style.display = "block";
        } else {
            urlDiv.style.display = "none";
            localeDiv.style.display = "none";
        }
        integrationCheck.addEventListener('change', function(){
            if (this.checked) {
                urlDiv.style.display = "block";
                localeDiv.style.display = "block";
            } else {
                urlDiv.style.display = "none";
                localeDiv.style.display = "none";
            }
        })
    }
    // check validity of urls when input looses focus
    inputUrl.addEventListener("blur", checkUrl)
    function checkUrl(event){
        const values = event.target.value;
        const errors = [];
        values.split(",").forEach(function(value){
            try {
                // if value is not valid, it will throw a TypeError
                const url = new URL(value);
            } catch(error){
                errors.push(error);
            }
        })
        if(errors.length !== 0 && inputUrl.parentNode.lastChild === inputUrl){
            // create p
            const elem = document.createElement('p');
            // create content
            const newContent = document.createTextNode("There is an invalid url");
            // add content to p
            elem.appendChild(newContent);
            // add style and class to p
            elem.style.color = "red";
            elem.classList.add('url_input_error');
            // insert p after input
            inputUrl.after(elem);
        } else if(errors.length === 0 && inputUrl.parentNode.lastChild !== inputUrl){
            const elem = document.querySelector('p.url_input_error');
            inputUrl.parentNode.removeChild(elem);
        }
    }
})
