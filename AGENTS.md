# AGENT.MD

Huong dan cho AI/agent khi code trong project `Bank_Core`.

Muc tieu: code de hieu, de test, de mo rong, bam sat nghiep vu banking co ban, khong lam phuc tap qua muc can thiet.

## 1. Nguyen tac lam viec

- Doc code hien co truoc khi sua.
- Bam theo style, package, cach dat ten dang co trong project.
- Khong refactor lon neu task chi yeu cau sua nho.
- Khong xoa/sua thay doi cua user neu khong duoc yeu cau.
- Uu tien code chay duoc, ro nghiep vu, de giai thich khi phong van.
- Moi thay doi nen co ly do nghiep vu hoac ky thuat ro rang.

## 2. Kien truc module

Moi module nen di theo cau truc don gian:

```text
module
  auth
    controller
    dto
    service
    service/impl
  user
    entity
    repository
    service
  account
    entity
    repository
    service
  transfer
    controller
    dto
    entity
    repository
    service
```

Luong chuan:

```text
Controller -> Service -> Repository -> Database
```

Quy tac:

- Controller chi nhan request, goi service, tra response.
- Service chua nghiep vu chinh.
- Repository chi truy van database.
- DTO dung cho request/response.
- Entity chi map database, khong nhoi logic API.

## 3. SOLID

### Single Responsibility

Mot class chi nen co mot trach nhiem chinh.

Vi du:

- `AuthController`: API login/register.
- `AuthService`: xu ly login/register.
- `JwtService`: tao va validate JWT.
- `UserRepository`: truy van user.

Khong de controller vua query DB, vua hash password, vua tao token.

### Open/Closed

Code nen de mo rong ma khong phai sua nhieu noi.

Vi du:

- Them role `STAFF`, `ADMIN`, `CUSTOMER` thi khong sua lung tung o nhieu API.
- Dung enum/constant thay vi hard-code chuoi rai rac.

### Liskov Substitution

Implementation phai dung contract cua interface.

Vi du neu co `TransferService`, class `TransferServiceImpl` phai thuc hien dung y nghia method da khai bao.

### Interface Segregation

Khong tao interface qua to.

Khong tao `BankingService` gom auth, account, transfer, loan. Nen tach:

- `AuthService`
- `AccountService`
- `TransferService`
- `LoanService`

### Dependency Inversion

- Dung constructor injection.
- Khong dung field injection neu khong can.
- Khong tu `new Service()` hoac `new Repository()` trong service.

## 4. Design patterns nen dung

### DTO Pattern

Dung DTO de tach API data khoi entity.

Vi du:

- `LoginRequest`
- `RegisterRequest`
- `AuthResponse`
- `TransferRequest`

Khong tra thang `User` neu co truong nhay cam nhu `password`.

### Service Layer Pattern

Nghiep vu quan trong phai di qua service:

- Login qua `AuthService`.
- Chuyen tien qua `TransferService`.
- Mo tai khoan qua `AccountService`.
- Tao khoan vay qua `LoanService`.

### Repository Pattern

Repository chi lam viec voi database:

- `findByEmail`
- `existsByEmail`
- `findById`

Khong viet logic tao token, check permission, tinh phi trong repository.

### Nhom GoF thuc chien can tap trung

Khi user hoi ve design pattern hoac khi phan tich task, uu tien nhom pattern thuc chien sau:

```text
Singleton
Factory Method
Strategy
Proxy
Builder
```

DTO, Service Layer, Repository la pattern/kien truc ung dung can biet, nhung khi noi "nhom GoF" thi tap trung vao 5 pattern tren.

### Strategy Pattern

Dung khi co nhieu cach xu ly cung mot nghiep vu.

Vi du sau nay:

- Thanh toan qua Napas, Visa, VNPay, chuyen khoan noi bo.
- Tinh phi chuyen tien noi bo/lien ngan hang.
- Tinh lai khoan vay theo loai khoan vay.
- Gui notification qua EMAIL, SMS, IN_APP.

Chi dung khi code bat dau co nhieu `if/else` cung mot kieu.

### Factory Method

Dung khi can tao object theo loai.

Vi du:

- Tao account theo `PAYMENT`, `SAVING`, `LOAN`.
- Tao card theo `DEBIT`, `CREDIT`, `PREPAID`.
- Tao notification theo `EMAIL`, `SMS`, `IN_APP`.

Khong ap dung pattern chi de cho "xịn"; chi dung khi no lam code de hieu hon.

### Proxy Pattern

Can nhan ra trong Spring:

- `@Transactional`
- `@Cacheable`
- `@Async`
- AOP

Giai thich ngan:

```text
Spring tao proxy boc quanh method. Proxy chen logic mo transaction/cache/async truoc hoac sau method that.
```

### Singleton Pattern

Spring Bean mac dinh la singleton.

Giai thich ngan:

```text
Service/Repository thuong chi co mot instance trong Spring container va duoc inject vao noi can dung.
```

### Builder Pattern

Dung khi tao object/DTO co nhieu field.

Vi du:

- `AuthResponse.builder()...build()`
- Test data builder.
- DTO response nhieu optional field.

Khong bat buoc dung Builder neu object chi co it field.

## 5. Nguyen tac Security/Auth

- Password phai hash bang `PasswordEncoder`.
- Khong luu plain text password.
- Login thanh cong moi tra JWT.
- JWT chi nen chua thong tin can thiet: `userId`, `email`, `role`.
- API nhay cam phai yeu cau authentication.
- API quan tri phai check role/permission.
- Khong log password, full token, secret key.
- Secret key khong hard-code trong Java code; nen de trong config/env.
- Phan biet:
  - Authentication: ban la ai?
  - Authorization: ban duoc lam gi?

## 6. RBAC

Role co ban:

- `CUSTOMER`: khach hang.
- `STAFF`: nhan vien.
- `ADMIN`: quan tri.

Phan quyen goi y:

- `CUSTOMER`: xem tai khoan cua minh, chuyen tien, xem lich su giao dich cua minh.
- `STAFF`: xem ho so khach hang, xu ly KYC/loan co ban.
- `ADMIN`: quan ly user, role, cau hinh he thong.

Quy tac quan trong:

- Khong cho user tu truyen `userId` de xem du lieu nguoi khac neu co the lay user tu JWT.
- API nao lien quan tien/phien dang nhap/quyen han phai check user hien tai.

## 7. Nguyen tac banking co ban

- Giao dich tien phai dung database transaction.
- Khong cho so du am neu nghiep vu khong cho phep thau chi.
- Moi giao dich nen co status: `PENDING`, `SUCCESS`, `FAILED`.
- Khong xoa lich su giao dich tuy tien.
- Can audit log cho hanh dong quan trong: login, transfer, lock account, approve loan.
- Transfer phai check:
  - Tai khoan nguon ton tai.
  - Tai khoan dich ton tai.
  - Tai khoan nguon/dich dang active.
  - So du du.
  - So tien hop le.

## 8. Validation va error handling

- Request DTO dung validation annotation:
  - `@NotBlank`
  - `@Email`
  - `@NotNull`
  - `@Positive`
- Khong tra raw exception ra client.
- Dung response format thong nhat neu project da co.
- Message loi nen ngan gon, de hieu:
  - `Email already exists`
  - `Invalid email or password`
  - `Insufficient balance`
  - `Account is locked`

## 9. Transaction

Dung `@Transactional` tai service method co thay doi du lieu quan trong.

Vi du:

- Chuyen tien.
- Tao khoan vay.
- Thanh toan khoan vay.
- Khoa/mo tai khoan.

Khong dat transaction o controller.

## 10. Testing

Uu tien test phan co rui ro:

- Auth login/register.
- JWT generate/validate.
- Transfer du tien/khong du tien.
- Khong cho user xem du lieu cua nguoi khac.
- Loan tinh lich tra no co ban.

Test it nhung dung trong tam tot hon test nhieu ma khong cham vao nghiep vu.

## 11. Quy tac dat ten

- Class: `PascalCase`, vi du `AuthService`, `JwtService`.
- Method/variable: `camelCase`, vi du `findByEmail`, `accessToken`.
- Package: chu thuong, vi du `module.auth.service`.
- Request DTO: `LoginRequest`, `RegisterRequest`.
- Response DTO: `AuthResponse`, `UserResponse`.
- Entity enum nen ro nghia: `UserStatus`, `TransactionStatus`, `TransactionType`.

## 12. Checklist truoc khi xong task

- Code compile duoc.
- API chay duoc neu task co API.
- Co validation request.
- Co xu ly loi co ban.
- Khong lo password/token/secret.
- Controller khong chua nghiep vu nang.
- Repository khong chua nghiep vu.
- Service ro trach nhiem.
- Khong lam phuc tap qua muc can thiet.

## 13. Cach lam viec voi moi task cua user

Moi khi user giao task, agent phai di theo flow nay truoc khi code hoac giai thich.

### 13.1 Phan tich bai toan

Can noi ro:

- Task nay thuoc module nao?
- Muc tieu nghiep vu la gi?
- Input la gi?
- Output la gi?
- Du lieu nao can doc/ghi?
- Co lien quan tien, bao mat, quyen truy cap hay transaction khong?

Vi du:

```text
Task transfer tien thuoc module transfer.
Input: fromAccountId, toAccountId, amount.
Output: transaction result.
Rui ro: lost update, insufficient balance, duplicate transaction.
Can @Transactional va locking.
```

### 13.2 De xuat cau truc du lieu / collection

Khi code co xu ly list/map/set, agent phai giai thich:

- Nen dung `List`, `Set`, `Map`, `Queue` hay object rieng?
- Tai sao dung cau truc do?
- Do phuc tap hoac loi ich la gi?

Vi du:

```text
Dung Set cho authorities vi role/permission khong nen bi duplicate.
Dung Map<UUID, Account> khi can lookup account theo id nhanh.
Dung List khi can giu thu tu lich tra no.
```

### 13.3 Nhan dien design pattern

Neu task co lien quan pattern, agent phai chi ra pattern dang dung de user on phong van.

Phan thanh 2 nhom:

Nhom kien truc ung dung:

- Service Layer: Controller -> Service -> Repository.
- Repository Pattern: Spring Data JpaRepository.
- DTO Pattern: request/response khong tra entity truc tiep.

Nhom GoF/thuc chien uu tien:

- Strategy Pattern: Napas/Visa/VNPay, tinh phi/lai theo tung loai.
- Factory Method: tao account/card/notification theo type.
- Proxy Pattern: `@Transactional`, `@Cacheable`.
- Singleton Pattern: Spring Bean mac dinh.
- Builder Pattern: tao DTO/object nhieu field ro rang.

Agent phai tranh ke qua nhieu pattern neu user dang on Junior; chi noi them pattern khac khi that su lien quan.

### 13.4 Xem co can ACID / transaction / locking khong

Voi task lien quan tien hoac update nhieu bang, agent phai hoi va giai thich:

- Co can `@Transactional` khong?
- Co nguy co lost update khong?
- Nen dung optimistic lock hay pessimistic lock?
- Neu loi giua chung thi rollback the nao?

Vi du:

```text
Transfer tien can @Transactional vi tru tien, cong tien, ghi transaction phai atomic.
Can lock account de tranh 2 request rut tien cung luc lam sai balance.
```

### 13.5 Xem co nen dung Redis khong

Chi goi y Redis khi co ly do ro:

- OTP voi TTL.
- Cache du lieu doc nhieu.
- Rate limiting.
- Distributed lock neu that su can.

Khong goi y Redis cho moi bai toan.

Vi du:

```text
OTP nen dung Redis vi co TTL tu xoa sau 5 phut.
Loan product co the cache vi doc nhieu, it thay doi.
Balance cache phai can than vi lien quan tien.
```

### 13.6 Xem co nen dung Kafka khong

Chi goi y Kafka khi can bat dong bo hoac decouple.

Phu hop:

- Transfer success -> notification.
- Transfer success -> audit log.
- Loan approved -> notification.

Khong phu hop:

- Logic can response ngay.
- Logic can transaction atomic trong cung DB.
- Project dang hoc monolith co ban va chua can async.

Vi du:

```text
Notification sau transfer nen dung Kafka vi email fail khong nen lam transfer fail.
```

### 13.7 Phan bien lai de user hoc

Sau khi dua giai phap, agent phai phan bien ngan:

- Diem manh cua giai phap.
- Diem yeu/trade-off.
- Truong hop nao khong nen dung.
- Cau hoi phong van co the bi hoi.

Vi du:

```text
Dung Kafka cho notification giup transfer nhanh va decouple, nhung tang phuc tap infra va eventual consistency. Neu project nho, co the dung ApplicationEvent truoc.
```

### 13.8 Uu tien hoc Junior

Khi task lien quan TPBank Junior, agent phai uu tien:

1. Java Core + OOP.
2. Spring Boot + JPA + Security.
3. Database: ACID, index, lock.
4. Redis 3 use case: OTP, cache, rate limit.
5. Kafka: producer/consumer, tai sao dung.
6. Microservice: concept, API Gateway, khi nao khong nen dung.
7. Design Pattern: tap trung Singleton, Factory Method, Strategy, Proxy, Builder.

Khong day user di qua sau vao:

- Kafka exactly-once.
- Kafka Streams.
- Redis Cluster/Sentinel.
- Kubernetes nang cao.
- Service Mesh.
- Saga/Event Sourcing implement chi tiet.

### 13.9 Format tra loi khi user muon tu code

Neu user noi muon tu code, agent khong code het ngay. Agent phai dua:

- Luong chuc nang.
- Class can tao.
- Method can viet.
- Thu tu code tung buoc.
- Goi y loi hay gap.
- Sau khi user code xong thi review va giai thich.

Vi du format:

```text
Buoc 1: tao DTO.
Buoc 2: tao Repository.
Buoc 3: viet Service method.
Buoc 4: viet Controller.
Buoc 5: test bang Postman.
```
