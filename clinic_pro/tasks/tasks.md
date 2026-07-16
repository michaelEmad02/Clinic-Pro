
 ## clinics
- [ ] create fetchAllStaffUseCase  that will use `Staff repo` and will show all staff to select one of theme , to add him to the clinic.
        - will do it after create fetchAllStaff function in `staff feature`
- [ ] create Future<Either<Failure, List<StaffEntity>>> fecthClinicStaff  in `Clinics repo` .
        - will do this after create `StaffEntity`

- [X] implement addStaff in `clinics_remote_data_source` 
        - will do that after build `staff model`.

- [ ] create `FetchClinicStaffUseCas` , `FetchClinicStaffCubit` , and refactor `ClinicStaffSection`.

- [ ] when add staff from existing users , if the user select secretary will show widget for select the doctor.


## staff
- [ ] create staff details screen.
- [ ] add deleteStaffFromClinic method , and use it in clinic feature 


## auth

- [ ] مراجعه انشاء حساب المالك .
- [ ] قبول ورفض الدعوات.
- [ ] after accept , will save staff data in `clinicStaff` table , and if the staff is secretary will add to `doctor_secretary` table .
- [ ] التسجيل من خلال جوجل - و الرابط السريع .