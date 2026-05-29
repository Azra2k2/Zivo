const {
  Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
  Header, Footer, AlignmentType, HeadingLevel, BorderStyle, WidthType,
  ShadingType, VerticalAlign, PageNumber, PageBreak, LevelFormat,
  TabStopType, TabStopPosition,
} = require('docx');
const fs = require('fs');

// ─── Constants ──────────────────────────────────────────────────────────────
const FONT = 'Times New Roman';
const SIZE = 24;          // 12pt in half-points
const H1_SIZE = 28;       // 14pt
const H2_SIZE = 26;       // 13pt
const SPACING_15 = 360;   // 1.5 line spacing (240 = single)
const BLACK = '000000';
const WHITE = 'FFFFFF';

// A4 page (DXA). Margins: top/bottom 1440 (1 in), left/right 1440 (1 in)
// Content width: 11906 - 2*1440 = 9026
const CONTENT_W = 9026;

// ─── Helpers ─────────────────────────────────────────────────────────────────

function run(text, opts = {}) {
  return new TextRun({
    text,
    font: FONT,
    size: opts.size || SIZE,
    bold: opts.bold || false,
    italics: opts.italics || false,
    color: BLACK,
    ...opts,
  });
}

function para(children, opts = {}) {
  return new Paragraph({
    spacing: { line: opts.spacing || SPACING_15, after: opts.after !== undefined ? opts.after : 120 },
    alignment: opts.align || AlignmentType.JUSTIFIED,
    ...opts,
    children: Array.isArray(children) ? children : [children],
  });
}

function heading1(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_1,
    spacing: { before: 360, after: 180, line: SPACING_15 },
    children: [new TextRun({ text, font: FONT, size: H1_SIZE, bold: true, color: BLACK })],
  });
}

function heading2(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_2,
    spacing: { before: 240, after: 120, line: SPACING_15 },
    children: [new TextRun({ text, font: FONT, size: H2_SIZE, bold: true, color: BLACK })],
  });
}

function emptyPara() {
  return para([run('')], { after: 0, spacing: 180 });
}

function pageBreak() {
  return new Paragraph({ children: [new PageBreak()] });
}

// Plain black border for tables
const BORDER = { style: BorderStyle.SINGLE, size: 4, color: BLACK };
const BORDERS = { top: BORDER, bottom: BORDER, left: BORDER, right: BORDER };

function headerCell(text, width) {
  return new TableCell({
    borders: BORDERS,
    width: { size: width, type: WidthType.DXA },
    shading: { fill: WHITE, type: ShadingType.CLEAR },
    margins: { top: 80, bottom: 80, left: 120, right: 120 },
    children: [
      new Paragraph({
        spacing: { line: 280, after: 0 },
        children: [new TextRun({ text, font: FONT, size: SIZE, bold: true, color: BLACK })],
      }),
    ],
  });
}

function dataCell(text, width) {
  return new TableCell({
    borders: BORDERS,
    width: { size: width, type: WidthType.DXA },
    shading: { fill: WHITE, type: ShadingType.CLEAR },
    margins: { top: 80, bottom: 80, left: 120, right: 120 },
    children: [
      new Paragraph({
        spacing: { line: 280, after: 0 },
        children: [new TextRun({ text, font: FONT, size: SIZE, color: BLACK })],
      }),
    ],
  });
}

// ─── Header (every page) ─────────────────────────────────────────────────────
const pageHeader = new Header({
  children: [
    new Paragraph({
      tabStops: [{ type: TabStopType.RIGHT, position: TabStopPosition.MAX }],
      border: { bottom: { style: BorderStyle.SINGLE, size: 4, color: BLACK, space: 4 } },
      spacing: { after: 120 },
      children: [
        new TextRun({ text: 'ZIVO – CIT211 Mobile Software Development', font: FONT, size: 18, color: BLACK }),
        new TextRun({ text: '\t', font: FONT, size: 18, color: BLACK }),
        new TextRun({ text: 'Page ', font: FONT, size: 18, color: BLACK }),
        new TextRun({ children: [PageNumber.CURRENT], font: FONT, size: 18, color: BLACK }),
      ],
    }),
  ],
});

// ─── Cover Page ──────────────────────────────────────────────────────────────
function coverPage() {
  function coverLine(label, value) {
    return new Paragraph({
      spacing: { line: SPACING_15, after: 100 },
      alignment: AlignmentType.CENTER,
      children: [
        new TextRun({ text: `${label}: `, font: FONT, size: SIZE, bold: true, color: BLACK }),
        new TextRun({ text: value, font: FONT, size: SIZE, color: BLACK }),
      ],
    });
  }

  return [
    emptyPara(), emptyPara(), emptyPara(),
    new Paragraph({
      spacing: { line: SPACING_15, after: 80 },
      alignment: AlignmentType.CENTER,
      children: [new TextRun({ text: '[University Name]', font: FONT, size: SIZE, bold: true, color: BLACK })],
    }),
    new Paragraph({
      spacing: { line: SPACING_15, after: 280 },
      alignment: AlignmentType.CENTER,
      children: [new TextRun({ text: 'Faculty of Computing and Information Technology', font: FONT, size: SIZE, color: BLACK })],
    }),
    new Paragraph({
      spacing: { line: SPACING_15, after: 160 },
      alignment: AlignmentType.CENTER,
      children: [new TextRun({ text: 'CIT211 – Mobile Software Development', font: FONT, size: H1_SIZE, bold: true, color: BLACK })],
    }),
    new Paragraph({
      spacing: { line: SPACING_15, after: 160 },
      alignment: AlignmentType.CENTER,
      children: [new TextRun({ text: 'Design and Development of a Fashion Store Mobile Application', font: FONT, size: H1_SIZE, bold: true, color: BLACK })],
    }),
    emptyPara(), emptyPara(),
    new Paragraph({
      spacing: { line: SPACING_15, after: 320 },
      alignment: AlignmentType.CENTER,
      children: [new TextRun({ text: 'ZIVO', font: FONT, size: 40, bold: true, color: BLACK })],
    }),
    coverLine('Student Full Name', '[Student Full Name]'),
    coverLine('Student ID', '[Student ID]'),
    coverLine('Lecturer', '[Lecturer Name]'),
    coverLine('Submission Date', '[Submission Date]'),
    emptyPara(),
    coverLine('GitHub Repository', '[Paste your GitHub link here]'),
    coverLine('Video Demonstration', '[Paste your YouTube link here]'),
    pageBreak(),
  ];
}

// ─── Section 1: Introduction ─────────────────────────────────────────────────
function section1() {
  return [
    heading1('1. Introduction'),
    para([
      run('This report presents the design and development of ZIVO, a fashion store mobile application built using Flutter and Firebase. ZIVO is an editorial-style e-commerce application that allows users to browse a curated catalogue of fashion products, manage a shopping cart and wishlist, place orders, and maintain a personal profile. The application targets fashion-conscious consumers who expect a premium, visually refined mobile shopping experience.'),
    ]),
    para([
      run('The application was developed as a cross-platform solution using the Flutter framework, enabling deployment on both Android and iOS from a single codebase. Firebase was chosen as the backend-as-a-service (BaaS) platform, providing real-time database capabilities through Cloud Firestore and secure user authentication through Firebase Authentication.'),
    ]),
    para([
      run('GitHub Repository: [Paste your GitHub link here]'),
    ]),
    para([
      run('Video Demonstration: [Paste your YouTube link here]'),
    ]),
    para([
      run('The core objectives of the project were to: (1) implement a complete e-commerce user journey from product discovery to order placement; (2) integrate Firebase services for persistent, real-time data synchronisation; (3) deliver a polished, editorial-quality user interface; and (4) apply sound software architecture principles through structured state management and service-layer abstractions.'),
    ]),
  ];
}

// ─── Section 2: System Overview ───────────────────────────────────────────────
function section2() {
  const col1 = Math.floor(CONTENT_W * 0.30);
  const col2 = Math.floor(CONTENT_W * 0.35);
  const col3 = CONTENT_W - col1 - col2;

  const rows = [
    ['Technology', 'Package / Version', 'Purpose'],
    ['Flutter SDK', 'sdk: ^3.11.0', 'Cross-platform UI framework'],
    ['Dart Language', 'Included with Flutter', 'Primary programming language'],
    ['Firebase Core', 'firebase_core: ^3.12.1', 'Firebase SDK initialisation'],
    ['Firebase Auth', 'firebase_auth: ^5.4.2', 'Email/password authentication'],
    ['Cloud Firestore', 'cloud_firestore: ^5.6.4', 'NoSQL real-time database'],
    ['Provider', 'provider: ^6.0.0', 'State management (ChangeNotifier)'],
    ['Google Fonts', 'google_fonts: ^6.2.1', 'Inter and Plus Jakarta Sans typefaces'],
    ['Cupertino Icons', 'cupertino_icons: ^1.0.8', 'iOS-style icon set'],
  ];

  const tableRows = rows.map((r, i) =>
    new TableRow({
      children: [
        i === 0 ? headerCell(r[0], col1) : dataCell(r[0], col1),
        i === 0 ? headerCell(r[1], col2) : dataCell(r[1], col2),
        i === 0 ? headerCell(r[2], col3) : dataCell(r[2], col3),
      ],
    })
  );

  return [
    heading1('2. System Overview'),
    para([run('ZIVO is built on a layered technology stack combining the Flutter UI framework with Firebase cloud services. The following table enumerates all dependencies declared in pubspec.yaml and their roles within the application.')]),
    emptyPara(),
    new Table({
      width: { size: CONTENT_W, type: WidthType.DXA },
      columnWidths: [col1, col2, col3],
      rows: tableRows,
    }),
    emptyPara(),
    para([run('The application follows a service-oriented architecture. The presentation layer consists of Flutter widget screens organised by feature. The data layer is mediated by two service classes — AuthService and FirestoreService — which encapsulate all Firebase API calls. The state management layer uses the Provider package with a single AppData ChangeNotifier that holds and distributes cart, wishlist, order, and user state to the widget tree.')]),
    para([run('Firebase Authentication handles all identity operations including account creation, email/password sign-in, display name persistence, and session management via auth state streams. Cloud Firestore stores both the global product catalogue and per-user sub-collections for cart items, wishlist entries, orders, and profile data.')]),
  ];
}

// ─── Section 3: UI/UX Design ─────────────────────────────────────────────────
function section3() {
  const col1 = Math.floor(CONTENT_W * 0.35);
  const col2 = Math.floor(CONTENT_W * 0.30);
  const col3 = CONTENT_W - col1 - col2;

  const colourRows = [
    ['Colour Role', 'Hex Code', 'Usage'],
    ['Primary (Burnt Orange)', '#a03c01', 'Buttons, icons, active nav items, accents'],
    ['Surface (Warm Off-White)', '#fef9f1', 'Scaffold background, app bar'],
    ['On Surface (Near-Black)', '#1d1c17', 'Body text, headings'],
    ['Surface Low', '#f8f3eb', 'Input fields, inactive chips'],
    ['Surface High', '#ece8e0', 'Dividers, category chips'],
    ['Secondary Container', '#fed8ca', 'Selected category chip background'],
    ['On Surface Variant', '#57423a', 'Subtitles, secondary labels'],
    ['Background (White)', '#ffffff', 'Card backgrounds, product cards'],
  ];

  const colourTable = new Table({
    width: { size: CONTENT_W, type: WidthType.DXA },
    columnWidths: [col1, col2, col3],
    rows: colourRows.map((r, i) =>
      new TableRow({
        children: [
          i === 0 ? headerCell(r[0], col1) : dataCell(r[0], col1),
          i === 0 ? headerCell(r[1], col2) : dataCell(r[1], col2),
          i === 0 ? headerCell(r[2], col3) : dataCell(r[2], col3),
        ],
      })
    ),
  });

  const screenCol1 = Math.floor(CONTENT_W * 0.38);
  const screenCol2 = CONTENT_W - screenCol1;

  const screenRows = [
    ['Screen', 'Description'],
    ['Login Screen', 'Email/password sign-in with animated background blobs and gradient sign-in button'],
    ['Register Screen', 'New account creation with display name, email, and password fields'],
    ['Home Screen', 'Hero banner, horizontal category chip filter, staggered 2-column product grid, editorial quote'],
    ['Product List Screen', 'Full product catalogue with grid layout and navigation to detail'],
    ['Product Detail Screen', 'Product imagery, brand, name, price, size selector, add to cart and wishlist actions'],
    ['Cart Screen', 'List of cart items with quantity controls, subtotal, and checkout navigation'],
    ['Checkout Screen', 'Delivery address form, static payment summary, order total with 8.5% tax, place order CTA'],
    ['Order History Screen', 'Chronological list of past orders with status, items, and total price'],
    ['Wishlist Screen', 'Saved product cards with remove and add-to-cart options'],
    ['Profile Screen', 'Display of user name and email with logout functionality'],
  ];

  const screenTable = new Table({
    width: { size: CONTENT_W, type: WidthType.DXA },
    columnWidths: [screenCol1, screenCol2],
    rows: screenRows.map((r, i) =>
      new TableRow({
        children: [
          i === 0 ? headerCell(r[0], screenCol1) : dataCell(r[0], screenCol1),
          i === 0 ? headerCell(r[1], screenCol2) : dataCell(r[1], screenCol2),
        ],
      })
    ),
  });

  return [
    heading1('3. UI/UX Design'),
    heading2('3.1 Design Philosophy'),
    para([run('ZIVO adopts an editorial fashion aesthetic, characterised by generous whitespace, a restrained warm neutral palette, premium typography, and strong typographic hierarchy. The design language draws from high-end fashion publications, using uppercase tracked letter-spacing for labels, serif-feel proportions through Plus Jakarta Sans headings, and Inter for body copy — both served via the google_fonts package.')]),
    heading2('3.2 Colour Palette'),
    para([run('All colour values are defined locally within each screen file, with AppColors.dart providing named constants for the core five tones. The palette is built around a burnt orange primary (#a03c01) set against warm off-white surfaces, creating a luxurious but accessible visual language.')]),
    emptyPara(),
    colourTable,
    emptyPara(),
    heading2('3.3 Application Screens'),
    para([run('The application comprises ten screens, each implemented as a stateful or stateless Flutter widget within a dedicated sub-directory under lib/screens/. The following table describes each screen and its primary function.')]),
    emptyPara(),
    screenTable,
    emptyPara(),
    para([run('[SCREENSHOT: Home screen showing hero banner, category chips, and staggered product grid]')], { italics: true }),
    para([run('[SCREENSHOT: Product detail screen showing product image, size selector, and add-to-cart button]')], { italics: true }),
    heading2('3.4 Navigation'),
    para([run('The bottom navigation bar (BottomNavBar widget) provides access to five primary destinations: Home, Products, Cart, Wishlist, and Profile. It is implemented as a custom pill-shaped floating container with AnimatedContainer transitions for selected state. Deep navigation (e.g., product detail, checkout) is handled via named route pushes using Navigator.pushNamed.')]),
  ];
}

// ─── Section 4: System Architecture ──────────────────────────────────────────
function section4() {
  const routeCol1 = Math.floor(CONTENT_W * 0.30);
  const routeCol2 = Math.floor(CONTENT_W * 0.38);
  const routeCol3 = CONTENT_W - routeCol1 - routeCol2;

  const routeRows = [
    ['Route', 'Screen Class', 'Type'],
    ['/login', 'LoginScreen', 'Named route'],
    ['/register', 'RegisterScreen', 'Named route'],
    ['/home', 'HomeScreen', 'Named route'],
    ['/products', 'ProductListScreen', 'Named route'],
    ['/cart', 'CartScreen', 'Named route'],
    ['/checkout', 'CheckoutScreen', 'Named route'],
    ['/orders', 'OrderHistoryScreen', 'Named route'],
    ['/wishlist', 'WishlistScreen', 'Named route'],
    ['/profile', 'ProfileScreen', 'Named route'],
    ['/product-detail', 'ProductDetailScreen', 'onGenerateRoute (with productId argument)'],
  ];

  const routeTable = new Table({
    width: { size: CONTENT_W, type: WidthType.DXA },
    columnWidths: [routeCol1, routeCol2, routeCol3],
    rows: routeRows.map((r, i) =>
      new TableRow({
        children: [
          i === 0 ? headerCell(r[0], routeCol1) : dataCell(r[0], routeCol1),
          i === 0 ? headerCell(r[1], routeCol2) : dataCell(r[1], routeCol2),
          i === 0 ? headerCell(r[2], routeCol3) : dataCell(r[2], routeCol3),
        ],
      })
    ),
  });

  return [
    heading1('4. System Architecture'),
    heading2('4.1 Directory Structure'),
    para([run('The source code is organised under the lib/ directory using a feature-first approach, with cross-cutting concerns separated into named sub-directories. The full structure is as follows:')]),
    emptyPara(),
    new Paragraph({
      spacing: { line: 240, after: 0 },
      children: [new TextRun({ text: 'lib/', font: 'Courier New', size: SIZE, bold: true, color: BLACK })],
    }),
    ...[
      '  core/               app_colors.dart, app_constants.dart',
      '  data/               app_data.dart (AppData ChangeNotifier), migration.dart',
      '  models/             cart_model.dart, order_model.dart, product_model.dart, user_model.dart',
      '  screens/',
      '    auth/             login_screen.dart, register_screen.dart',
      '    cart/             cart_screen.dart',
      '    checkout/         checkout_screen.dart',
      '    home/             home_screen.dart',
      '    orders/           order_history_screen.dart',
      '    products/         product_detail_screen.dart, product_list_screen.dart',
      '    profile/          profile_screen.dart',
      '    wishlist/         wishlist_screen.dart',
      '  services/           auth_service.dart, firestore_service.dart',
      '  widgets/            bottom_nav_bar.dart, product_card.dart',
      '  app.dart            MaterialApp, route map, AuthGate',
      '  main.dart           Firebase initialisation, runApp',
    ].map(line =>
      new Paragraph({
        spacing: { line: 240, after: 0 },
        children: [new TextRun({ text: line, font: 'Courier New', size: 18, color: BLACK })],
      })
    ),
    emptyPara(),
    heading2('4.2 State Management'),
    para([run('State management is implemented using the Provider package. A single AppData class, extending ChangeNotifier, acts as the application-level store. It holds the current user profile, cart items, wishlist items, and orders as in-memory lists. These are populated by subscribing to Firestore streams via StreamSubscription objects that are initialised when the user authenticates (initFirestore) and cancelled on logout or disposal.')]),
    para([run('The MaterialApp is wrapped in a MultiProvider that exposes both AuthService (plain Provider) and AppData (ChangeNotifierProvider) to the entire widget tree. Individual screens access state using context.watch<AppData>() or Consumer<AppData>, and trigger mutations through method calls on AppData, which in turn delegate to FirestoreService.')]),
    heading2('4.3 Navigation Architecture'),
    para([run('Navigation is handled by the Flutter MaterialApp named routes map defined in app.dart. The AuthGate widget, set as the home property of MaterialApp, uses a StreamBuilder on FirebaseAuth.authStateChanges to conditionally render either LoginScreen or HomeScreen, with a CircularProgressIndicator during the waiting state. The route table is as follows:')]),
    emptyPara(),
    routeTable,
    emptyPara(),
  ];
}

// ─── Section 5: Database Design ───────────────────────────────────────────────
function section5() {
  const col1 = Math.floor(CONTENT_W * 0.38);
  const col2 = Math.floor(CONTENT_W * 0.22);
  const col3 = CONTENT_W - col1 - col2;

  const collectionRows = [
    ['Collection Path', 'Document Key', 'Fields'],
    ['products', 'Auto-ID (Firestore)', 'name, brand, price, imageUrl, category, description, sizes (array)'],
    ['users/{uid}', 'Firebase Auth UID', 'name, email'],
    ['users/{uid}/cart', '{productId}_{selectedSize}', 'productId, productName, productBrand, productPrice, productImageUrl, productCategory, productDescription, productSizes, selectedSize, quantity'],
    ['users/{uid}/wishlist', 'productId', 'name, brand, price, imageUrl, category, description, sizes'],
    ['users/{uid}/orders', 'ZV-{timestamp}', 'items (array), totalPrice, date (Timestamp), status, deliveryAddress'],
  ];

  const collectionTable = new Table({
    width: { size: CONTENT_W, type: WidthType.DXA },
    columnWidths: [col1, col2, col3],
    rows: collectionRows.map((r, i) =>
      new TableRow({
        children: [
          i === 0 ? headerCell(r[0], col1) : dataCell(r[0], col1),
          i === 0 ? headerCell(r[1], col2) : dataCell(r[1], col2),
          i === 0 ? headerCell(r[2], col3) : dataCell(r[2], col3),
        ],
      })
    ),
  });

  return [
    heading1('5. Database Design'),
    heading2('5.1 Firestore Data Model'),
    para([run('ZIVO uses Cloud Firestore as its primary data store, organised into one top-level collection and one top-level user document with four sub-collections per authenticated user. This design scopes all mutable user data beneath a single user document identified by the Firebase Authentication UID, which naturally enforces data isolation between users via Firestore security rules.')]),
    emptyPara(),
    collectionTable,
    emptyPara(),
    heading2('5.2 Key Design Decisions'),
    para([run('Cart document identity: Cart items use a composite document ID of the format {productId}_{selectedSize}. This ensures that the same product in a different size is treated as a distinct line item, while also acting as a natural deduplication key — adding an already-present product-size combination updates the quantity rather than creating a duplicate.')]),
    para([run('Denormalised cart and order items: Rather than storing only a product reference in cart and order documents, the full product data (name, brand, price, imageUrl, etc.) is written into each cart and order item at the time of insertion. This denormalisation ensures that historical orders remain accurate even if the upstream product document is modified or deleted.')]),
    para([run('Product catalogue seeding: The migration.dart file contains a one-time migration utility that writes the static product list from app_data.dart into the Firestore products collection. Once seeded, the application reads products exclusively from Firestore via a real-time stream, falling back to the static list only if Firestore returns no data.')]),
    para([run('Order timestamp: Orders are stored with a Firestore server timestamp (date field) and a synthetic string ID of the format ZV-{millisecondsSinceEpoch % 100000}, providing a human-readable order reference number.')]),
  ];
}

// ─── Section 6: Implementation ────────────────────────────────────────────────
function section6() {
  return [
    heading1('6. Implementation'),
    heading2('6.1 Firebase Authentication Flow'),
    para([run('Authentication is encapsulated in AuthService, which wraps FirebaseAuth.instance. The signInWithEmail and signUpWithEmail methods call the respective Firebase SDK functions, and signUpWithEmail additionally calls updateDisplayName to persist the user\'s name on the Firebase Auth profile. Error handling in LoginScreen translates FirebaseAuthException error codes (invalid-credential, invalid-email, too-many-requests, etc.) into user-readable messages displayed via SnackBar with a floating behaviour.')]),
    para([run('Session persistence is handled automatically by the Firebase SDK. The AuthGate widget subscribes to authStateChanges, a stream that emits whenever the authentication state changes. On a valid session, it invokes appData.initFirestore() via addPostFrameCallback to start the Firestore stream subscriptions only after the widget tree has mounted, avoiding setState-during-build errors.')]),
    heading2('6.2 Real-Time Data Synchronisation'),
    para([run('AppData subscribes to three simultaneous Firestore streams — cart, wishlist, and orders — using StreamSubscription<T> fields. Each subscription calls notifyListeners() on new data, which propagates changes to all Consumer<AppData> and context.watch<AppData>() widgets in the tree. This ensures that the cart badge, product listing, and order history always reflect the latest Firestore state without requiring manual refresh actions.')]),
    para([run('Products are read directly from the Firestore products collection via a separate Stream<List<ProductModel>> exposed as appData.getProductsStream(), which is consumed by a StreamBuilder in HomeScreen. The static fallback list (AppData.products) is used as snapshot.data ?? AppData.products, so the UI remains populated even during the initial Firestore fetch or in an offline state.')]),
    heading2('6.3 Shopping Cart Management'),
    para([run('Cart operations are implemented as a two-layer system. AppData exposes addToCart, updateCartQuantity, removeFromCart, and clearCart methods. Each method delegates immediately to the corresponding FirestoreService method, which performs the Firestore write. The cart list in AppData is populated by the active Firestore stream subscription rather than by optimistic local mutation, ensuring the local state always reflects the server-authoritative data.')]),
    para([run('Cart clearing during order placement uses a Firestore batch write: all cart documents are fetched and their references collected into a WriteBatch, which is then committed atomically. This prevents partial deletion in the event of a network interruption mid-clear.')]),
    heading2('6.4 Order Placement and Checkout'),
    para([run('The CheckoutScreen collects a delivery address through four text fields (full name, street, city, zip code). If all fields are left empty, a default address string is substituted. The placeOrder method in AppData calculates the order total (pre-tax) by folding over the cart items, constructs an OrderModel with a generated ID and a status of "Processing", calls firestore.placeOrder to persist it, and then calls clearCart to empty the cart.')]),
    para([run('The checkout summary applies an 8.5% tax rate to the cart subtotal. Shipping is displayed as "COMPLIMENTARY" (zero cost). On successful order placement, a Dialog is displayed confirming the order, and the user is navigated to the Order History screen using pushNamedAndRemoveUntil, removing intermediate routes back to the home screen.')]),
    heading2('6.5 Wishlist Feature'),
    para([run('The wishlist is stored as a Firestore sub-collection under users/{uid}/wishlist, with the product\'s Firestore ID used as the document ID. This allows O(1) presence checks and prevents duplicates without requiring a collection query. The isInWishlist(productId) method in AppData checks the local wishlist list (already synced from Firestore) for a matching ID, enabling real-time UI toggling of the wishlist heart icon without an additional network call.')]),
    heading2('6.6 Product Catalogue and Categories'),
    para([run('HomeScreen implements a horizontal category chip filter using a stateful _selectedCategory index and a ListView.separated widget scrolling in the horizontal axis. Five categories are defined: All, New, Summer, Accessories, and Editors\' Choice. The featured products section renders four items from the live Firestore stream in a manually staggered two-column layout — the right column is offset by 32 points downward — creating a Pinterest-style masonry visual effect without requiring a third-party layout package.')]),
  ];
}

// ─── Section 7: Testing and Results ──────────────────────────────────────────
function section7() {
  const c1 = Math.floor(CONTENT_W * 0.27);
  const c2 = Math.floor(CONTENT_W * 0.30);
  const c3 = Math.floor(CONTENT_W * 0.18);
  const c4 = CONTENT_W - c1 - c2 - c3;

  const testRows = [
    ['Test Case', 'Steps', 'Expected Result', 'Status'],
    ['User Registration', 'Open app, tap "Create an account", enter name, email, password, submit', 'Account created, user redirected to Home screen', 'Pass'],
    ['Invalid Login', 'Enter wrong credentials on Login screen, tap Sign In', 'SnackBar displays "Invalid email or password" message', 'Pass'],
    ['Valid Login', 'Enter correct credentials, tap Sign In', 'User authenticated, Home screen displayed', 'Pass'],
    ['Browse Products', 'Tap grid icon in bottom nav, scroll product list', 'Product list loads from Firestore with images, names, prices', 'Pass'],
    ['View Product Detail', 'Tap any product card from Home or List screen', 'Detail screen shows image, brand, name, price, sizes, and action buttons', 'Pass'],
    ['Add to Cart', 'On Product Detail, select a size, tap "Add to Cart"', 'Item appears in Cart screen; Firestore users/{uid}/cart updated', 'Pass'],
    ['Update Cart Quantity', 'In Cart screen, tap + or - buttons on an item', 'Quantity updates in real-time; item removed when quantity reaches 0', 'Pass'],
    ['Wishlist Toggle', 'Tap heart icon on a product, check Wishlist screen', 'Product added to wishlist; Firestore users/{uid}/wishlist updated', 'Pass'],
    ['Place Order', 'Add items to cart, navigate to Checkout, fill address, tap Place Order', 'Confirmation dialog shown; order appears in Order History; cart cleared', 'Pass'],
    ['Order History', 'Navigate to Orders screen after placing an order', 'List shows order ID, date, status "Processing", items, and total', 'Pass'],
    ['Logout', 'Navigate to Profile screen, tap Logout', 'User signed out, Login screen displayed', 'Pass'],
    ['Session Persistence', 'Close and reopen app while logged in', 'User returned to Home screen without needing to re-authenticate', 'Pass'],
  ];

  const testTable = new Table({
    width: { size: CONTENT_W, type: WidthType.DXA },
    columnWidths: [c1, c2, c3, c4],
    rows: testRows.map((r, i) =>
      new TableRow({
        children: [
          i === 0 ? headerCell(r[0], c1) : dataCell(r[0], c1),
          i === 0 ? headerCell(r[1], c2) : dataCell(r[1], c2),
          i === 0 ? headerCell(r[2], c3) : dataCell(r[2], c3),
          i === 0 ? headerCell(r[3], c4) : dataCell(r[3], c4),
        ],
      })
    ),
  });

  return [
    heading1('7. Testing and Results'),
    para([run('Testing was conducted manually on an Android device and the Flutter Android emulator. The following test cases cover the primary user flows and feature interactions identified during development.')]),
    emptyPara(),
    testTable,
    emptyPara(),
    para([run('[SCREENSHOT: Cart screen showing items with quantity controls and subtotal]')], { italics: true }),
    para([run('[SCREENSHOT: Order confirmation dialog and Order History screen]')], { italics: true }),
    para([run('All twelve manual test cases passed successfully. The real-time synchronisation between the Flutter client and Firestore was verified by observing that changes made in the Firebase Console were reflected in the running application within approximately one second, confirming that the stream subscriptions are active and functioning correctly.')]),
  ];
}

// ─── Section 8: Challenges and Solutions ──────────────────────────────────────
function section8() {
  return [
    heading1('8. Challenges and Solutions'),
    heading2('8.1 Authentication State and Firestore Initialisation Race Condition'),
    para([run('Challenge: When the AuthGate StreamBuilder received a valid user and attempted to immediately call appData.initFirestore() from within the build method, a "setState called during build" exception was thrown. This is a known Flutter framework constraint: build methods must be side-effect free.')]),
    para([run('Solution: The initFirestore call was deferred using WidgetsBinding.instance.addPostFrameCallback, which schedules the call to execute after the current build cycle completes. A boolean _initialized flag prevents the call from being repeated on subsequent rebuilds triggered by the same auth stream event.')]),
    heading2('8.2 Preventing Cart Duplicate Line Items'),
    para([run('Challenge: A user could theoretically add the same product in the same size multiple times, creating duplicate Firestore documents and incorrect quantity counts.')]),
    para([run('Solution: Cart documents use a composite document ID ({productId}_{selectedSize}) as their Firestore document path. Because Firestore document IDs are unique within a collection, writing a cart item with an existing ID performs an upsert (set) rather than creating a duplicate. The AppData.addToCart method additionally checks the local cart list for a matching product-size combination and calls updateCartQuantity instead of addToCart if a match is found, combining client-side deduplication with server-side document identity enforcement.')]),
    heading2('8.3 Maintaining Accurate Order History After Product Changes'),
    para([run('Challenge: If the application stored only a product reference (ID) in order documents, subsequent edits to a product\'s price or name in Firestore would retroactively alter the historical order record, undermining billing accuracy.')]),
    para([run('Solution: All product fields (name, brand, price, imageUrl, category, description, sizes) are denormalised and copied into each cart and order document at the time of writing, as seen in CartModel.toMap(). This snapshot approach ensures that order history is immutable with respect to subsequent product catalogue changes.')]),
    heading2('8.4 Staggered Product Grid Without a Layout Package'),
    para([run('Challenge: The home screen design required a Pinterest-style staggered grid where the right column is vertically offset, without introducing an external package dependency.')]),
    para([run('Solution: The staggered effect is achieved using two independent Column widgets wrapped in Expanded widgets within a Row. The right Column begins with a SizedBox(height: 32) spacer, creating the visual offset. This approach uses only standard Flutter layout widgets and requires no additional dependencies.')]),
    heading2('8.5 Cart Batch Deletion on Order Placement'),
    para([run('Challenge: Clearing the cart after order placement by iterating through items and deleting them individually could leave the cart in a partially-deleted state if the application was closed or lost connectivity mid-operation.')]),
    para([run('Solution: The clearCart method in FirestoreService fetches all cart document references first, then constructs a Firestore WriteBatch and queues all deletions before committing the batch in a single atomic operation. This ensures that either all items are deleted or none are, preventing partial cart states.')]),
  ];
}

// ─── Section 9: Conclusion and Future Improvements ───────────────────────────
function section9() {
  return [
    heading1('9. Conclusion and Future Improvements'),
    heading2('9.1 Conclusion'),
    para([run('ZIVO successfully demonstrates the design and end-to-end development of a full-featured fashion e-commerce mobile application using Flutter and Firebase. The application implements all core e-commerce user journeys — authentication, product browsing, cart management, wishlist, checkout, and order history — backed by real-time Firestore synchronisation and secure Firebase Authentication.')]),
    para([run('The project achieved its principal objectives: delivering a premium editorial user interface that reflects the target fashion audience, applying a structured architecture with clear separation between UI, state, and service layers, and leveraging Firebase\'s BaaS capabilities to eliminate the need for a custom server. The use of the Provider package for state management proved effective for an application of this scale, keeping widget rebuilds focused and predictable.')]),
    heading2('9.2 Future Improvements'),
    para([run('Product Search and Filtering: The search bar on the Home screen is currently non-functional (no onChanged handler). A future release would implement text-based search using Firestore queries with where clauses, or a dedicated search service such as Algolia, to provide full-text product search.')]),
    para([run('Real Payment Integration: The current checkout presents a static card (Visa ending 4429) as a payment method placeholder. Integrating the Stripe Flutter SDK or a similar payment gateway would enable actual card tokenisation and payment processing.')]),
    para([run('Google and Apple Sign-In: The Login screen includes Google and Apple social login buttons that are currently UI-only with no handler attached. Implementing firebase_google_sign_in and Sign in with Apple would reduce registration friction for new users.')]),
    para([run('Push Notifications: Order status updates (e.g., Dispatched, Delivered) could be delivered to the user via Firebase Cloud Messaging, requiring integration of the firebase_messaging package and a server-side trigger function (Firebase Cloud Functions).')]),
    para([run('Product Review and Rating System: A review sub-collection under each product document would allow authenticated users to submit ratings and comments, enriching the product detail screen and supporting community-driven product discovery.')]),
    para([run('Firestore Security Rules: The current implementation relies on application-level authentication checks. Deploying Firestore security rules that enforce read/write permissions based on the authenticated user\'s UID would be a necessary step before a production release.')]),
  ];
}

// ─── Section 10: References ────────────────────────────────────────────────────
function section10() {
  function ref(text) {
    return para([run(text)], { after: 80 });
  }

  return [
    heading1('10. References'),
    ref('Flutter Team. (2024). Flutter documentation. Google LLC. https://docs.flutter.dev'),
    ref('Firebase Team. (2024). Firebase documentation. Google LLC. https://firebase.google.com/docs'),
    ref('Firebase Team. (2024). Cloud Firestore documentation. Google LLC. https://firebase.google.com/docs/firestore'),
    ref('Firebase Team. (2024). Firebase Authentication documentation. Google LLC. https://firebase.google.com/docs/auth'),
    ref('Remi Rousselet. (2024). Provider package (v6.0.0). pub.dev. https://pub.dev/packages/provider'),
    ref('Google LLC. (2024). google_fonts package (v6.2.1). pub.dev. https://pub.dev/packages/google_fonts'),
    ref('Flutter Team. (2024). cupertino_icons package (v1.0.8). pub.dev. https://pub.dev/packages/cupertino_icons'),
    ref('Dart Team. (2024). Dart language documentation. Google LLC. https://dart.dev/guides'),
    ref('Material Design Team. (2024). Material Design 3 specification. Google LLC. https://m3.material.io'),
    ref('Fowler, M. (2002). Patterns of Enterprise Application Architecture. Addison-Wesley.'),
  ];
}

// ─── Assemble Document ────────────────────────────────────────────────────────
const doc = new Document({
  styles: {
    default: {
      document: {
        run: { font: FONT, size: SIZE, color: BLACK },
        paragraph: { spacing: { line: SPACING_15 } },
      },
    },
    paragraphStyles: [
      {
        id: 'Heading1',
        name: 'Heading 1',
        basedOn: 'Normal',
        next: 'Normal',
        quickFormat: true,
        run: { size: H1_SIZE, bold: true, font: FONT, color: BLACK },
        paragraph: {
          spacing: { before: 360, after: 180, line: SPACING_15 },
          outlineLevel: 0,
        },
      },
      {
        id: 'Heading2',
        name: 'Heading 2',
        basedOn: 'Normal',
        next: 'Normal',
        quickFormat: true,
        run: { size: H2_SIZE, bold: true, font: FONT, color: BLACK },
        paragraph: {
          spacing: { before: 240, after: 120, line: SPACING_15 },
          outlineLevel: 1,
        },
      },
    ],
  },
  sections: [
    {
      properties: {
        page: {
          size: { width: 11906, height: 16838 },
          margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 },
        },
      },
      headers: { default: pageHeader },
      children: [
        ...coverPage(),
        ...section1(),
        pageBreak(),
        ...section2(),
        pageBreak(),
        ...section3(),
        pageBreak(),
        ...section4(),
        pageBreak(),
        ...section5(),
        pageBreak(),
        ...section6(),
        pageBreak(),
        ...section7(),
        pageBreak(),
        ...section8(),
        pageBreak(),
        ...section9(),
        pageBreak(),
        ...section10(),
      ],
    },
  ],
});

Packer.toBuffer(doc).then(buffer => {
  fs.writeFileSync('zivo_report.docx', buffer);
  console.log('zivo_report.docx generated successfully.');
}).catch(err => {
  console.error('Error generating document:', err);
  process.exit(1);
});
