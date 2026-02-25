class AppStrings {
  AppStrings._();

  // App
  static const String appName     = 'Asi & Obra';
  static const String appTagline  = 'Bem vindo ao\nAsi & Obra!';
  static const String appSubtitle = 'Gestão de Estoque';

  // Auth
  static const String login           = 'Login';
  static const String register        = 'Cadastro';
  static const String criarConta      = 'Criar conta';
  static const String cadastrar       = 'Entrar';
  static const String logout          = 'Sair';
  static const String email           = 'Insira seu e-mail';
  static const String password        = 'Digite sua Senha';
  static const String confirmPassword = 'Repita sua Senha';
  static const String name            = 'Digite seu nome';
  static const String forgotPassword  = 'Esqueci minha senha';
  static const String noAccount       = 'Não possui uma conta? ';
  static const String hasAccount      = 'Já possui uma conta? ';
  static const String doRegister      = 'Realize o cadastro';
  static const String doLogin         = 'Realize o login';

  // Roles
  static const String roleAdmin      = 'Administrador';
  static const String roleEstoquista = 'Estoquista';
  static const String roleLeitor     = 'Leitor';

  // Nav
  static const String home      = 'Início';
  static const String profile   = 'Perfil';
  static const String products  = 'Produtos';
  static const String inventory = 'Estoque';

  // Produtos
  static const String productName        = 'Nome do produto';
  static const String productType        = 'Tipo';
  static const String productBrand       = 'Marca';
  static const String productDescription = 'Descrição';
  static const String addProduct         = 'Novo produto';
  static const String editProduct        = 'Editar produto';
  static const String noProducts         = 'Nenhum produto cadastrado.';

  // Estoque
  static const String batchNumber     = 'Número do lote';
  static const String initialQuantity = 'Quantidade inicial';
  static const String currentQuantity = 'Quantidade atual';
  static const String expirationDate  = 'Data de validade';
  static const String addInventory    = 'Novo lote';
  static const String editInventory   = 'Editar lote';
  static const String noInventory     = 'Nenhum lote cadastrado.';

  // Baixa
  static const String stockOut         = 'Registrar Baixa';
  static const String stockOutQuantity = 'Quantidade';
  static const String stockOutReason   = 'Motivo da baixa';

  // Ações
  static const String save    = 'Salvar';
  static const String cancel  = 'Cancelar';
  static const String edit    = 'Editar';
  static const String delete  = 'Excluir';
  static const String confirm = 'Confirmar';
  static const String search  = 'Buscar...';

  // Validações
  static const String fieldRequired = 'Campo obrigatório';
  static const String invalidEmail  = 'E-mail inválido';
  static const String passwordMin   = 'Mínimo 6 caracteres';
  static const String passwordMatch = 'As senhas não coincidem';
  static const String invalidQty    = 'Quantidade inválida';

  // Feedback
  static const String successSave   = 'Salvo com sucesso!';
  static const String successDelete = 'Excluído com sucesso!';
  static const String errorGeneric  = 'Ocorreu um erro. Tente novamente.';
  static const String noPermission  = 'Você não tem permissão para esta ação.';
  static const String confirmDelete = 'Deseja excluir este item?';
  static const String undoneAction  = 'Esta ação não pode ser desfeita.';
}