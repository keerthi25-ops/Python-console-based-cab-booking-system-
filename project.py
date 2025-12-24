ḍfrom pymysql import*
import pwinput as pw
import threading
import time
import re
def normalize_place(text):
    return re.sub(r'[^A-Z]', '', text.upper().strip())
class cabbooking:
    def __init__(self):
        self.con=connect(host='localhost',user='root',password='Keerthi2506',database='projectdb')
        self.stop_polling=False
    def customer(self,name,phone,email,pas):
        try:
            self.n=name
            self.ph=phone
            self.em=email
            q="insert into customer_account(name,phone,email,pass_word)values('{0}',{1},'{2}','{3}')".format(name,phone,email,pas)
            c=self.con.cursor()
            c.execute(q)
            self.con.commit()
            print('ACCOUNT CREATED')
            print('USERNAME:',phone)
            print('USE THIS USERNAME AND PASSWORD TO LOGIN')
        except Exception as e:
            print('ERROR CREATING ACCOUNT',e)
            self.con.rollback()
    def driver(self,name,phone,vehno,pas):
        try:
            self.n=name
            self.ph=phone
            self.v=vehno
            self.pas=pas
            q="insert into driver_account(name,phone,vehicleno,pass_word)values('{0}',{1},'{2}','{3}')".format(name,phone,vehno,pas)
            c=self.con.cursor()
            res=c.execute(q)
            self.con.commit()
            print('ACCOUNT CREATED')
            print('username:',self.ph)
            print('USE THIS USERNAME AND PASSWORD TO LOGIN')
        except Exception as e:
            print('ERROR CREATING ACCOUNT',e)
            self.con.rollback()
    def login(self,uname,pwd):
        try:
            q="select *from login where username={0} and pass_word='{1}'".format(uname,pwd)
            c=self.con.cursor()
            c.execute(q)
            res=c.fetchall()
            cnt=len(res)
            self.con.commit()
            print('login successfully' if cnt>=1 else'"login failed",may be register first or put your login details correctly')
        except Exception as e:
            print('ERROR LOGIN',e)
            self.con.rollback()
    def myaccount(self,role,phno):
        try:
            self.r=role
            self.p=phno
            c=self.con.cursor()
            if role==1:
                q="select id,name,phone,email from customer_account where phone=%s"
                c.execute(q,(phno,))
                data=c.fetchone()
                if data is None:
                    print('no account found')
                else:
                    print("Customer details:")
                    print("ID:", data[0])                   
                    print("Name:", data[1])                   
                    print("Phone:", data[2])                   
                    print("Email:", data[3])
                
            elif role==2:
                q="select id,name,phone,vehicleno from driver_account where phone=%s"
                c.execute(q,(phno,))
                data=c.fetchone()
                if data is None:
                    print('no account found')
                else:
                    print("Driver details:")
                    print("ID:", data[0])                   
                    print("Name:", data[1])                   
                    print("Phone:", data[2])                   
                    print("Vehicle:", data[3])                   
            else:
                print('invalid role')
        except Exception as e:
            print('ERROR VIEWING YOUR ACCOUNT',e)
            self.con.rollback()
    def bookings(self, cusid, cusname, pick, drp):
        try:
            self.c = cusid
            self.p = pick
            self.d = drp
            base_rate = 15
            c = self.con.cursor()
            x = "SELECT id FROM customer_account WHERE id=%s"
            c.execute(x, (cusid,))
            data = c.fetchone()
            if data is None:
                print('Account does not exist')
                return None
            q ="SELECT km FROM city_distance WHERE source=%s AND destination=%s"
            c.execute(q, (pick,drp))
            data1 = c.fetchone()
            if data1 is None:
                print('Distance out of range')
                return None
            k=data1[0]
            km=float(k)
            pay=base_rate*km
            q1 = "SELECT id, name, phone, vehicleno FROM driver_account WHERE availability=%s LIMIT 1"
            c.execute(q1, ('available',))
            data2 = c.fetchone()
            if data2 is None:
                print('No driver available')
                return None
            driver_id, driver_name, driver_phone, vehicle_no = data2
            print(f"Driver: {driver_name}")
            print(f"Phone: {driver_phone}")
            print(f"Vehicle: {vehicle_no}")
            q2 = "INSERT INTO bookings(cus_id, cus_name, dri_id, pickup, dropat, payment) VALUES(%s, %s, %s, %s, %s, %s)"
            c.execute(q2, (cusid, cusname, driver_id, pick, drp, pay))
            booking_id = c.lastrowid
            q3 = "UPDATE driver_account SET availability=%s WHERE id=%s"
            c.execute(q3, ('booked', driver_id))
            self.con.commit()
            print(f"BOOKED: {booking_id}")
            print(f"PAYMENT: ₹{pay}\n")
            return booking_id
        
        except Exception as e:
            print(f"ERROR: {e}")
            self.con.rollback()
            return None
  
    def cancel(self,bookingid):
        try:
            c=self.con.cursor()
            q="update bookings SET status=%s WHERE booking_id=%s and status not in ('cancelled', 'completed'))"
            c.execute(q,('cancelled',bookingid,))
            if c.rowcount == 0:
                print("Cannot cancel: booking not found or already completed/cancelled.")           
                return
            c.execute("SELECT dri_id FROM bookings WHERE booking_id = %s", (bookingid,))
            dri = c.fetchone()
            if dri:
                c.execute("UPDATE driver_account SET availability = %s WHERE id = %s", ('available', dri[0]))

            self.con.commit()
            print("Booking cancelled successfully.")
        except Exception as e:
            print('ERROR CANCEL BOOKING:',e)
            self.con.rollback()

    def riding_status(self,bookingid):
        try:
           c=self.con.cursor()
           q="select * from ride_status where booking_id=%s"
           c.execute(q,(bookingid,))
           data=c.fetchall()
           if not data:
               print('no bookings found')
           else:
               booking_id,status,update=data[0]
               print(f"bookingid:{booking_id}")
               print(f"status:{status}")
               print(f"update:{update}")
               choice = input("\nWant auto-updates? (yes/no): ").lower()
               if choice == 'yes':
                   self.stop_polling = False
                   self.auto_display(bookingid)
                   input("\nPress Enter to stop auto-updates and return to menu...")
                   self.stop_polling = True
        except Exception as e:
            print('ERROR:',e)
            self.con.rollback()
    def auto_display(self, booking_id, interval=300):
        def poll():
            while not self.stop_polling:
                try:
                    with self.con.cursor() as c:
                        q = "SELECT booking_id, status, last_update FROM ride_status WHERE booking_id=%s"
                        c.execute(q, (booking_id,))
                        row = c.fetchone()

                        if row:
                            bid, status, last_update = row
                            print("\n===================================")
                            print(f"AUTO STATUS UPDATE FOR BOOKING {bid}")
                            print(f"Status      : {status}")
                            print(f"Last Update : {last_update}")
                            print("=====================================")
                        else:
                            print(f"\nNo ride status found for booking ID {booking_id}")

                    time.sleep(interval)

                except Exception as e:
                    print("Error reading ride status:", e)
                    time.sleep(interval)

        thread = threading.Thread(target=poll, daemon=True)
        thread.start()
        return thread
def main():
    cb=cabbooking()
    if cb.con is None:
        print("Cannot start application without database connection.")
        return
    while True:
        print("\n" + "="*60)
        print("          WELCOME TO CAB BOOKING SYSTEM")
        print("="*60)
        print("1. Create Customer Account")
        print("2. Create Driver Account")
        print("3. Login")
        print("4. View My Account")
        print("5. Book a Cab")
        print("6. Cancel Booking")
        print("7. Check Ride Status")
        print("8. Exit")
        print("="*60)
        opt=int(input('choose option:'))
        if opt==1:
            try:
                n=input('enter name:').strip().upper().lower()
                p=int(input('enter ph no:'))
                e=input('enter email:').lower()
                pd=pw.pwinput(prompt='enter password:',mask='*').strip()
                cb.customer(n,p,e,pd)
            except Exception as e:
                print('enter the correct input:',e)
        elif opt==2:
            try:
                n=input('enter name:').strip().upper().lower()
                p=int(input('enter ph no:'))
                v=input('enter vehicle no(XX-XX-XXXX):').strip()
                pd=pw.pwinput(prompt='enter password:',mask='*').strip()
                cb.driver(n,p,v,pd)
            except Exception as e:
                print('enter the correct input:',e)
        elif opt==3:
            try:
                u=input('enter username:')
                pd=pw.pwinput(prompt='enter password:',mask='*').strip()
                cb.login(u,pd)
            except Exception as e:
                print('enter the correct input:',e)
        elif opt==4:
            try:
                r=int(input('enter role 1.customer 2.driver:'))
                p=int(input('enter ph no:'))
                cb.myaccount(r,p)
            except Exception as e:
                print('enter the correct input:',e)
        elif opt==5:
            try:
                print('need customer id for bookings')
                cid=int(input('enter id:'))
                cname=input('enter name:').strip()
                pi=normalize_place(input('pickupat(area):'))
                dr=normalize_place(input('dropat(area):'))
                cb.bookings(cid,cname,pi,dr)
            except Exception as e:
                print('enter the correct input:',e)
        elif opt==6:
            try:
                bkid=int(input('enter booking id:'))
                cb.cancel(bkid)
            except Exception as e:
                print('enter the correct input:',e)
        elif opt==7:
            try:
                bk=int(input('enter booking id:'))
                cb.riding_status(bk)
            except Exception as e:
                print('enter the correct input:',e)
        elif opt==8:
            print("\n" + "="*60)
            print("Thank you for using CAB BOOKING SYSTEM!")
            print('BOOK YOUR RIDE SOON:)')
            print("="*60 + "\n")
            break
        else:
            print('invalid option')    

if __name__ == "__main__":
    main()
