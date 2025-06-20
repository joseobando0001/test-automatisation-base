Feature: BBE_EXAM_001

  Background:
    * configure ssl = true

  @GETCHARACTERS
  Scenario: Verificar que un endpoint público responde 200
    Given url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/testuser/api/characters'
    When method get
    Then status 200

  @GETCHARACTERSANDVALIDATESTRUCTURE
  Scenario: Validar estructura de cada personaje
    Given url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/testuser/api'
    And path '/characters'
    When method GET
    Then status 200

    And match each response ==
      """
      {
        id: '#number',
        name: '#string',
        alterego: '#string',
        description: '#string',
        powers: '#[]'
      }
      """

  @GETBYIDWITHERROR
  Scenario: Obtener personaje por ID (no existe)
    Given url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/testuser/api'
    And path '/characters/0'
    When method GET
    Then status 404
    And match response.error == 'Character not found'

  @CREATECHARACTER
  Scenario: Crear un nuevo personaje
    * def timestamp = java.lang.System.currentTimeMillis()
    * def uniqueName = 'Jose Obando ' + timestamp
    Given url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/testuser/api'
    And path '/characters'
    And request
      """
      {
        "name": "#(uniqueName)",
        "alterego": "Tony Stark",
        "description": "Genius billionaire",
        "powers": ["Armor", "Flight"]
      }
      """
    When method POST
    Then status 201

    And match response.name == '#(uniqueName)'
    And match response.alterego == 'Tony Stark'
    And match response.powers contains 'Armor'

  @DELETECHARACTER
  Scenario: Eliminar personaje "Jose Obando"
    * def timestamp = java.lang.System.currentTimeMillis()
    * def uniqueName = 'Jose Obando ' + timestamp
    Given url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/testuser/api'
    And path '/characters'
    When method GET
    Then status 200
    * def personaje = response.find(x => x.name == '#(uniqueName)')
    * if (!personaje) karate.fail('No se encontró el personaje creado')
    * if (personaje) karate.set('pId', personaje.id)
    Given path '/characters/' + pId
    When method DELETE
    Then status 204

  @CREATECHARACTERDUPLICATED
  Scenario: Crear un nuevo personaje (Nombre duplicado)
    Given url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/testuser/api'
    And path '/characters'
    And request
      """
      {
        "name": "Iron Man",
        "alterego": "Tony Stark",
        "description": "Genius billionaire",
        "powers": ["Armor", "Flight"]
      }
      """
    When method POST
    Then status 400
    And match response.error contains 'Character name already exists'


  @CREATECHARACTERWITHOUTNAME
  Scenario: Crear personaje (faltan campos requeridos) 'Name'

    Given url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/testuser/api'
    And path '/characters'
    And request
      """
      {
        "alterego": "Tony Stark",
        "description": "Genius billionaire",
        "powers": ["Armor", "Flight"]
      }
      """
    When method POST
    Then status 400
    And match response.name contains 'Name is required'

  @CREATECHARACTERWITHOUTPOWERS
  Scenario: Crear personaje (faltan campos requeridos) 'Powers'

    Given url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/testuser/api'
    And path '/characters'
    And request
      """
      {
        "name": "Jose Obando",
        "alterego": "Tony Stark",
        "description": "Genius billionaire",
      }
      """
    When method POST
    Then status 400
    And match response.powers contains 'Powers are required'


  @UPDATECHARACTER
  Scenario: Actualizar personaje "Jose Obando"
    Given url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/testuser/api'
    Given path '/characters'
    When method GET
    Then status 200
    * def personaje = response.find(x => x.name == 'Jose Obando')
    * def payload = {name: 'Jose Obando 1',alterego: 'Tony Stark',description: 'Genius billionaire',powers: ['Armor', 'Flight']}
    * if (personaje)  karate.set('path', '/characters/' + personaje.id)

    And request payload
    When method PUT

  @UPDATECHARACTERIFNOTEXISTS
  Scenario: Actualizar personaje "Jose Obando" y no existe
    Given url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/testuser/api/'
    And path '/characters/999999999'
    And request
      """
      {
        "name": "Jose Obando",
        "alterego": "Tony Stark",
        "description": "Genius billionaire",
        "powers": ["Armor", "Flight"]
      }
      """
    When method PUT
    Then status 404
    And match response.error contains 'Character not found'

  @UPDATECHARACTERANDCREATE
  Scenario: Actualizar personaje "Jose Obando" y Crear si no existe
    * def timestamp = java.lang.System.currentTimeMillis()
    * def uniqueName = 'Jose Obando ' + timestamp
    Given url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/testuser/api'
    Given path '/characters'
    When method GET
    Then status 200
    * def personaje = response.find(x => x.name == '#(uniqueName)')
    * def payload = {name: '#(uniqueName)',alterego: 'Tony Stark',description: 'Genius billionaire',powers: ['Armor', 'Flight']}
    * if (personaje)  karate.set('path', '/characters/')

    And request payload
    When method POST

  @DELETECHARACTERIFNOTEXISTS
  Scenario: Eliminar personaje y no existe
    Given url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/testuser/api/'
    And path '/characters/999999999'
    When method DELETE
    Then status 404
    And match response.error contains 'Character not found'
