#if !os(WASI)
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public extension Snapshotting where Value == URLRequest, Format == String {
    /// A snapshot strategy for comparing requests based on raw equality.
    ///
    /// ``` swift
    /// assertSnapshot(of: request, as: .raw)
    /// ```
    ///
    /// Records:
    ///
    /// ```
    /// POST http://localhost:8080/account
    /// Cookie: pf_session={"userId":"1"}
    ///
    /// email=blob%40pointfree.co&name=Blob
    /// ```
    static let raw = Snapshotting.raw(pretty: false)

    /// A snapshot strategy for comparing requests based on raw equality.
    ///
    /// - Parameter pretty: Attempts to pretty print the body of the request (supports JSON).
    static func raw(pretty: Bool) -> Snapshotting {
        SimplySnapshotting.lines.pullback { (request: URLRequest) in
            let method =
                "\(request.httpMethod ?? "GET") \(request.url?.sortingQueryItems()?.absoluteString ?? "(null)")"

            let headers = (request.allHTTPHeaderFields ?? [:])
                .map { key, value in "\(key): \(value)" }
                .sorted()

            let bodyData: Data?
            if pretty,
               let httpBody = request.httpBody,
               let object = try? JSONSerialization.jsonObject(with: httpBody, options: []),
               let prettyBody = try? JSONSerialization.data(
                   withJSONObject: object, options: [.prettyPrinted, .sortedKeys]
               ) {
                bodyData = prettyBody
            } else {
                bodyData = request.httpBody
            }
            let body = bodyData.map { ["\n\(String(lossyUTF8: $0))"] } ?? []

            return ([method] + headers + body).joined(separator: "\n")
        }
    }

    /// A snapshot strategy for comparing requests based on a cURL representation.
    ///
    /// ``` swift
    /// assertSnapshot(of: request, as: .curl)
    /// ```
    ///
    /// Records:
    ///
    /// ```
    /// curl \
    ///   --request POST \
    ///   --header "Accept: text/html" \
    ///   --data 'pricing[billing]=monthly&pricing[lane]=individual' \
    ///   "https://www.pointfree.co/subscribe"
    /// ```
    static let curl = SimplySnapshotting.lines.pullback { (request: URLRequest) in

        var components = ["curl"]

        // HTTP Method
        guard let httpMethod = request.httpMethod else {
            fatalError("URLRequest must have an HTTP method")
        }
        switch httpMethod {
            case "GET": break
            case "HEAD": components.append("--head")
            default: components.append("--request \(httpMethod)")
        }

        // Headers
        if let headers = request.allHTTPHeaderFields {
            for field in headers.keys.sorted() where field != "Cookie" {
                guard let value = headers[field] else {
                    fatalError("URLRequest header missing value")
                }
                let escapedValue = value.replacingOccurrences(of: "\"", with: "\\\"")
                components.append("--header \"\(field): \(escapedValue)\"")
            }
        }

        // Body
        if let httpBodyData = request.httpBody,
           let httpBody = String(data: httpBodyData, encoding: .utf8) {
            var escapedBody = httpBody.replacingOccurrences(of: "\\\"", with: "\\\\\"")
            escapedBody = escapedBody.replacingOccurrences(of: "\"", with: "\\\"")

            components.append("--data \"\(escapedBody)\"")
        }

        // Cookies
        if let cookie = request.allHTTPHeaderFields?["Cookie"] {
            let escapedValue = cookie.replacingOccurrences(of: "\"", with: "\\\"")
            components.append("--cookie \"\(escapedValue)\"")
        }

        // URL
        guard let url = request.url, let sortedURL = url.sortingQueryItems() else {
            fatalError("URLRequest must have a valid URL")
        }
        components.append("\"\(sortedURL.absoluteString)\"")

        return components.joined(separator: " \\\n\t")
    }
}

fileprivate extension URL {
    func sortingQueryItems() -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        let sortedQueryItems = components?.queryItems?.sorted { $0.name < $1.name }
        components?.queryItems = sortedQueryItems

        return components?.url
    }
}
#endif
