
 ## clinics
- [X] create fetchAllStaffUseCase  that will use `Staff repo` and will show all staff to select one of theme , to add him to the clinic.
        - will do it after create fetchAllStaff function in `staff feature`
- [X] create Future<Either<Failure, List<StaffEntity>>> fecthClinicStaff  in `Clinics repo` .
        - will do this after create `StaffEntity`

- [X] implement addStaff in `clinics_remote_data_source` 
        - will do that after build `staff model`.

- [X] create `FetchClinicStaffUseCas` , `FetchClinicStaffCubit` , and refactor `ClinicStaffSection`.

- [X] when add staff from existing users , if the user select secretary will show widget for select the doctor.

- [] add patients count in clinic details screen


## staff
- [X] add deleteStaffFromClinic method , and use it in clinic feature 
- [x]  عند حذف موظف , لو الموظف مش موجود في عياده اخري يتم حذف حسابه نهائيا


## appointments

- [x] تنفيذ العمليات المعتمده علي ال features  الاخري


## patients

- [x] implments patients prescriptions in patient details


## reports 
- [x] build doctor reports screen .will show doctor statistics, will display in bottom nav bar instad of expenses.
- [x] التحقق من سماحيه الوصول للتقارير حسب نوع الاشتراك


## improvements 
 - improve search (easy_debounce)
 - errors handling and the messages 
 - snackbar showing
 - network error page
 - loading widget
 - empty data widget
 - language
 - themes
 - local notifications
 

## reports
 - [x] عمل refresh indecator in reports
 - [x] implement date filters
 - [x] تحسين التقارير و المعلومات اللي بتظهر
 - [x] تحسين جلب البيانات (جلبها من السيرفر)

## subscriptions
 - [x] error handling
 - [x] show plans
 - [x] trail

## settings
- [] اضافه زر لحذف الحساب في حاله المالك
- [] about us 
- [] وضع اعدادات للمالك للتحكم في فتح تقارير الطبيب

## expenses
  - عمل مصاريف خاصه بالطبيب وليس العياده 

## features
- [x] auth
- [x] settings
- [x] clinics
- [x] staff_and_invitations
- [x] patients
- [x] appointments
- [x] prescriptions
- [x] invoices
- [ ] expenses
- [x] reports
- [ ] dashboard
- [x] subscriptions