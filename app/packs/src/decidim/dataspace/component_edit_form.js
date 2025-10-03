document.addEventListener("DOMContentLoaded", function(){
    const integrationCheck = document.querySelector('input#component_settings_add_integration')
    const urlDiv = document.querySelector("div.integration_url_container")
    if(integrationCheck){
        if(integrationCheck.checked){
            urlDiv.style.display = "block"
        } else {
            urlDiv.style.display = "none"
        }
        integrationCheck.addEventListener('change', function(){
            if (this.checked) {
                urlDiv.style.display = "block"
            } else {
                urlDiv.style.display = "none"
            }
        })
    }
})
