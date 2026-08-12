
 ## clinics
- [X] create fetchAllStaffUseCase  that will use `Staff repo` and will show all staff to select one of theme , to add him to the clinic.
        - will do it after create fetchAllStaff function in `staff feature`
- [X] create Future<Either<Failure, List<StaffEntity>>> fecthClinicStaff  in `Clinics repo` .
        - will do this after create `StaffEntity`

- [X] implement addStaff in `clinics_remote_data_source` 
        - will do that after build `staff model`.

- [X] create `FetchClinicStaffUseCas` , `FetchClinicStaffCubit` , and refactor `ClinicStaffSection`.

- [X] when add staff from existing users , if the user select secretary will show widget for select the doctor.


## staff
- [ ] create staff details screen.
- [X] add deleteStaffFromClinic method , and use it in clinic feature 


## appointments

- [x] تنفيذ العمليات المعتمده علي ال features  الاخري


## patients

- [x] implments patients prescriptions in patient details


## reports 
- [ ] build doctor reports screen .will show doctor statistics, will display in bottom nav bar instad of expenses.



## improvements 
 - improve search (easy_debounce)

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
- [ ] reports
- [ ] dashboard
- [ ] subscriptions