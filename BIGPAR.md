# Fork BigPar

Fork da calculadora da Receita, usado pelo SUPRA para simular CBS/IBS na precificação.

- **Atualizar:** no GitHub, "Sync fork" só quando quiser puxar mudanças da Receita. O deploy no Coolify
  roda os testes da Receita; se algum falhar, o build falha e a versão anterior continua no ar.
- **Deploy:** Coolify, Docker Compose (`docker-compose.yml`), sem porta publicada. O SUPRA chama
  `http://<serviço>:8080/api/calculadora/regime-geral` pela rede interna.
- **Saúde:** `http://localhost:9101/health` dentro do contêiner.
- **2027 em diante:** a API exige alíquotas nominais (`aliquotasNominais`), quem chama informa
  (CBS aprovada pelo TCU 11,3468%; IBS 0,05 + 0,05 em 2027).
- Arquivos só da BigPar: `Dockerfile`, `docker-compose.yml`, `.dockerignore`, `BIGPAR.md`.
  Não mexer no código da Receita, para o "Sync fork" não gerar conflito.
