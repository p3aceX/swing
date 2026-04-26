package Q0;

import android.os.Binder;
import android.os.IBinder;
import android.os.IInterface;
import android.os.Parcel;

/* JADX INFO: loaded from: classes.dex */
public abstract class i extends Binder implements IInterface {
    public i(String str) {
        attachInterface(this, str);
    }

    public abstract boolean a(int i4, Parcel parcel, Parcel parcel2, int i5);

    @Override // android.os.Binder
    public final boolean onTransact(int i4, Parcel parcel, Parcel parcel2, int i5) {
        if (i4 <= 16777215) {
            parcel.enforceInterface(getInterfaceDescriptor());
        } else if (super.onTransact(i4, parcel, parcel2, i5)) {
            return true;
        }
        return a(i4, parcel, parcel2, i5);
    }

    @Override // android.os.IInterface
    public final IBinder asBinder() {
        return this;
    }
}
