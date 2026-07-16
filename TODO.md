# TODO - Phase 2 RAG integration failure (frontend + upload)

- [x] Confirm backend `/documents/upload` lacked chunk/embed/upsert (file upload pipeline)
- [x] Fix backend: implement document indexing pipeline (extract text, chunk, embed, upsert to Chroma, set status)
- [x] Audit frontend document upload UI/state
- [x] Fix frontend: remove hardcoded mock file list and local upload simulation in `file_provider.dart`
- [x] Fix frontend: add `documents_repository.dart` with real API calls
- [x] Fix frontend: connect upload completion path to backend upload API
- [ ] Final frontend cleanup: remove remaining “Mock” UX strings/behaviors in `documents_screen.dart`
- [ ] Validate end-to-end from UI: upload file → backend indexes → UI refresh shows real document list

