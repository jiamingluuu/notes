A _RESTful API_ (aka. REST API) is an API that conforms to the constraints of REST architectural style and allows for interaction with RESTful web services.

## REST 
An API is considered RESTful if it satisfies:
- A client-server architecture made up of clients, servers, and resources, with requests managed though HTTP.
- Stateless Client-server communication.
- Cacheable data that streamlines client-server interactions.
- A uniform interface between components so that information is transferred in a standard form (JSON, HTML, XLT, plaintext, PNG, etc.), which means:
	- resources requested are identifiable and separate from the representations sent to the client.
	- resources can be manipulated by the client via the representation they receive because the representation contains enough information to do so.
	- self-descriptive message returned to the client have enough information to describe how the client should process it.