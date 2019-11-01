abstract class RestApiError extends Error {}

/// Thrown when an error is encountered when parsing JSON.
class InvalidJsonError extends RestApiError {}

/// Thrown when the user doesn't have a connection.
class NoConnectionError extends RestApiError {}

/// Thrown when no response is returned.
class NoResponseError extends RestApiError {}
