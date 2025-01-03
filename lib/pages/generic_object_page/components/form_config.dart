const formConfig = {
  "type": "column",
  "children": [
    {
      "type": "section",
      "title": "Informazioni Oggetto",
      "borderColor": "blue",
      "children": [
        {
          "type": "field",
          "label": "Nome",
          "controllerKey": "nameController",
          "fieldType": "text",
          "filter": {"enabled": true, "type": "text"}
        },
        {
          "type": "field",
          "label": "Descrizione",
          "controllerKey": "descriptionController",
          "fieldType": "text",
          "filter": {"enabled": true, "type": "text"}
        }
      ]
    },
    {
      "type": "section",
      "title": "Opzioni Aggiuntive",
      "borderColor": "green",
      "children": [
        {
          "type": "field",
          "label": "Categoria",
          "controllerKey": "categoryController",
          "fieldType": "categorical",
          "options": ["Opzione 1", "Opzione 2", "Opzione 3"],
          "filter": {"enabled": true, "type": "dropdown"}
        },
        {
          "type": "field",
          "label": "Data Evento",
          "controllerKey": "dateController",
          "fieldType": "date",
          "filter": {"enabled": false}
        }
      ]
    }
  ]
};
