# Architecture Review Checklist

> Comprehensive checklist for reviewing software architecture quality.

## SOLID Principles

### Single Responsibility (SRP)
- [ ] Each module has one reason to change
- [ ] Functions are small and focused
- [ ] Classes have clear purpose

### Open/Closed (OCP)
- [ ] Open for extension (interfaces, plugins)
- [ ] Closed for modification (stable core)
- [ ] New features added without changing existing code

### Liskov Substitution (LSP)
- [ ] Subtypes substitutable for base types
- [ ] No overriding that breaks behavior
- [ ] Contracts honored by all implementations

### Interface Segregation (ISP)
- [ ] Clients don't depend on unused methods
- [ ] Small, focused interfaces
- [ ] No "fat" interfaces

### Dependency Inversion (DIP)
- [ ] Depend on abstractions, not concretions
- [ ] Dependency injection used
- [ ] High-level modules not depend on low-level

## Module Coupling

- [ ] Low coupling between modules (max 5 dependencies)
- [ ] High cohesion within modules
- [ ] Clear module boundaries
- [ ] No circular dependencies
- [ ] Interface-based communication

## Layered Architecture

### Presentation Layer
- [ ] Only UI logic
- [ ] No business logic
- [ ] Delegates to business layer

### Business Layer
- [ ] Core logic
- [ ] No database access directly
- [ ] Uses data layer interfaces

### Data Layer
- [ ] Database access only
- [ ] No business logic
- [ ] Repository pattern used

## Error Handling

- [ ] Consistent error handling strategy
- [ ] Errors logged with context
- [ ] User-friendly messages
- [ ] Graceful degradation
- [ ] Proper exception types

## Scalability

- [ ] Stateless where possible
- [ ] Proper caching strategy
- [ ] Database queries optimized
- [ ] API rate limiting
- [ ] Horizontal scaling possible

## Security Architecture

- [ ] Authentication at edge
- [ ] Authorization per resource
- [ ] Secrets in environment variables
- [ ] Encryption for sensitive data
- [ ] Audit logging enabled

## Maintainability

- [ ] Clear naming conventions
- [ ] Documentation for public APIs
- [ ] Test coverage >= 80%
- [ ] Code review process
- [ ] CI/CD pipeline