package Q0;

import android.os.IBinder;
import android.os.IInterface;
import android.os.Parcel;

/* JADX INFO: renamed from: Q0.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0115a implements IInterface {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final IBinder f1512a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f1513b;

    public AbstractC0115a(IBinder iBinder, String str) {
        this.f1512a = iBinder;
        this.f1513b = str;
    }

    public final void a(int i4, Parcel parcel) {
        try {
            this.f1512a.transact(i4, parcel, null, 1);
        } finally {
            parcel.recycle();
        }
    }

    @Override // android.os.IInterface
    public final IBinder asBinder() {
        return this.f1512a;
    }
}
