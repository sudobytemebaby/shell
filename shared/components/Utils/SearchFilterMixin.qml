import QtQuick

/**
 * SearchFilterMixin
 *
 * Reusable search and filtering utilities with multiple matching strategies.
 * Provides consistent filtering behavior across Menu, Launcher, Emoji, and Wallpaper pickers.
 *
 * FEATURES:
 * - Multiple matching strategies (exact, contains, fuzzy, keyword)
 * - Case-insensitive matching
 * - Debounced filtering support
 * - Utility functions for common filtering patterns
 *
 * USAGE:
 * ```qml
 * Item {
 *   SearchFilterMixin {
 *     id: filterMixin
 *   }
 *
 *   function filterItems(searchText) {
 *     return allItems.filter(item => {
 *       return filterMixin.fuzzyMatch(item.name, searchText)
 *     })
 *   }
 * }
 * ```
 *
 * MATCHING STRATEGIES:
 * - exactMatch: Exact string match (case-insensitive)
 * - containsMatch: Substring match (most common)
 * - fuzzyMatch: Characters in order, not consecutive (flexible)
 * - keywordMatch: Match against multiple keywords/tags
 * - multiFieldMatch: Match against multiple object fields
 */
QtObject {
  id: root

  /**
   * Exact match (case-insensitive)
   * Returns true if text exactly equals query
   */
  function exactMatch(text, query) {
    if (!query) return true
    return text.toLowerCase() === query.toLowerCase()
  }

  /**
   * Contains match (case-insensitive substring)
   * Returns true if text contains query as a substring
   * Most common filtering strategy
   */
  function containsMatch(text, query) {
    if (!query) return true
    return text.toLowerCase().includes(query.toLowerCase())
  }

  /**
   * Fuzzy match - characters in order, not necessarily consecutive
   * Returns true if all characters in query appear in text in the same order
   *
   * Examples:
   * - fuzzyMatch("Firefox", "ffx") => true
   * - fuzzyMatch("Visual Studio Code", "vsc") => true
   * - fuzzyMatch("wallpaper", "wlpr") => true
   *
   * Used in: Wallpaper picker, App launcher
   */
  function fuzzyMatch(text, query) {
    if (!query) return true

    text = text.toLowerCase()
    query = query.toLowerCase()

    let queryIndex = 0
    for (let i = 0; i < text.length && queryIndex < query.length; i++) {
      if (text[i] === query[queryIndex]) {
        queryIndex++
      }
    }

    return queryIndex === query.length
  }

  /**
   * Keyword match - match against array of keywords/tags or string
   * Returns true if query matches any keyword
   *
   * Example:
   * - keywordMatch(["smile", "happy", "emotion"], "hap") => true
   * - keywordMatch("smile happy emotion", "hap") => true
   *
   * Used in: Emoji picker
   */
  function keywordMatch(keywords, query) {
    if (!query) return true
    if (!keywords || keywords.length === 0) return false

    const lowerQuery = query.toLowerCase()

    // Handle string keywords - treat as single keyword
    if (typeof keywords === 'string') {
      return keywords.toLowerCase().includes(lowerQuery)
    }

    // Handle array of keywords
    return keywords.some(keyword => {
      return keyword.toLowerCase().includes(lowerQuery)
    })
  }

  /**
   * Multi-field match - match against multiple object properties
   * Returns true if query matches any of the specified fields
   *
   * Example:
   * - multiFieldMatch(app, "firefox", ["name", "description", "executable"])
   *
   * Used in: App launcher, Menu items
   */
  function multiFieldMatch(item, query, fields) {
    if (!query) return true
    if (!item || !fields || fields.length === 0) return false

    const lowerQuery = query.toLowerCase()
    return fields.some(field => {
      const value = item[field]
      if (!value) return false
      return String(value).toLowerCase().includes(lowerQuery)
    })
  }

  /**
   * Filter array using contains match strategy
   * Convenience function for most common use case
   */
  function filterByContains(items, query, field) {
    if (!query) return items
    return items.filter(item => {
      const value = field ? item[field] : item
      return containsMatch(String(value), query)
    })
  }

  /**
   * Filter array using fuzzy match strategy
   * More flexible than contains, allows typing shortcuts
   */
  function filterByFuzzy(items, query, field) {
    if (!query) return items
    return items.filter(item => {
      const value = field ? item[field] : item
      return fuzzyMatch(String(value), query)
    })
  }

  /**
   * Filter array using keyword match strategy
   * Matches against array of keywords/tags
   */
  function filterByKeywords(items, query, keywordField) {
    if (!query) return items
    return items.filter(item => {
      const keywords = item[keywordField]
      return keywordMatch(keywords, query)
    })
  }

  /**
   * Filter array using multi-field match strategy
   * Searches across multiple properties
   */
  function filterByMultiField(items, query, fields) {
    if (!query) return items
    return items.filter(item => {
      return multiFieldMatch(item, query, fields)
    })
  }

  /**
   * Combined filter - matches if query appears in ANY field
   * Combines name, description, keywords, etc.
   *
   * Example usage (Emoji picker):
   * ```
   * filterCombined(emojis, "smile", {
   *   textFields: ["name"],
   *   keywordFields: ["keywords"]
   * })
   * ```
   */
  function filterCombined(items, query, config) {
    if (!query) return items

    const textFields = config.textFields || []
    const keywordFields = config.keywordFields || []

    return items.filter(item => {
      // Check text fields
      if (textFields.length > 0) {
        const textMatch = textFields.some(field => {
          const value = item[field]
          return value && containsMatch(String(value), query)
        })
        if (textMatch) return true
      }

      // Check keyword fields
      if (keywordFields.length > 0) {
        const kwMatch = keywordFields.some(field => {
          const keywords = item[field]
          return keywords && root.keywordMatch(keywords, query)
        })
        if (kwMatch) return true
      }

      return false
    })
  }

  /**
   * Sort filtered results by relevance
   * Prioritizes matches at the beginning of the string
   *
   * Returns: Array sorted by relevance score (higher = more relevant)
   */
  function sortByRelevance(items, query, field) {
    if (!query) return items

    const lowerQuery = query.toLowerCase()

    // Calculate relevance score for each item
    const scored = items.map(item => {
      const value = String(field ? item[field] : item).toLowerCase()
      let score = 0

      // Exact match: highest score
      if (value === lowerQuery) {
        score = 1000
      }
      // Starts with query: high score
      else if (value.startsWith(lowerQuery)) {
        score = 500
      }
      // Contains query: medium score
      else if (value.includes(lowerQuery)) {
        score = 100
      }
      // Fuzzy match: lower score
      else if (fuzzyMatch(value, lowerQuery)) {
        score = 10
      }

      return { item, score }
    })

    // Sort by score (descending) and return items
    scored.sort((a, b) => b.score - a.score)
    return scored.map(s => s.item)
  }

  /**
   * Highlight matching characters in text
   * Returns HTML with <b> tags around matching characters
   * Useful for search result highlighting
   */
  function highlightMatches(text, query) {
    if (!query) return text

    const lowerText = text.toLowerCase()
    const lowerQuery = query.toLowerCase()
    const index = lowerText.indexOf(lowerQuery)

    if (index === -1) return text

    const before = text.substring(0, index)
    const match = text.substring(index, index + query.length)
    const after = text.substring(index + query.length)

    return `${before}<b>${match}</b>${after}`
  }
}
