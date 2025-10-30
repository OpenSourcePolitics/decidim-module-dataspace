document.addEventListener("DOMContentLoaded", function(){
    const integrationCheck = document.querySelector('input#component_settings_add_integration')
    const urlDiv = document.querySelector("div.integration_url_container")
    const localeDiv = document.querySelector("div.preferred_locale_container")
    const inputUrl = document.querySelector("input[name='component[settings][integration_url]']")
    inputUrl.setAttribute("placeholder", "https://platform.com")

    if(integrationCheck){
        if(integrationCheck.checked){
            urlDiv.style.display = "block"
            localeDiv.style.display = "block"
        } else {
            urlDiv.style.display = "none"
            localeDiv.style.display = "none"
        }
        integrationCheck.addEventListener('change', function(){
            if (this.checked) {
                urlDiv.style.display = "block"
                localeDiv.style.display = "block"
            } else {
                urlDiv.style.display = "none"
                localeDiv.style.display = "none"
            }
        })
    }
})
