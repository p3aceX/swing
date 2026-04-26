package H;

import X.A;
import android.os.Parcel;
import android.os.Parcelable;
import k.c0;
import k.o0;

/* JADX INFO: loaded from: classes.dex */
public final class b implements Parcelable.ClassLoaderCreator {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f505a;

    public /* synthetic */ b(int i4) {
        this.f505a = i4;
    }

    @Override // android.os.Parcelable.ClassLoaderCreator
    public final Object createFromParcel(Parcel parcel, ClassLoader classLoader) {
        switch (this.f505a) {
            case 0:
                if (parcel.readParcelable(classLoader) == null) {
                    return c.f506b;
                }
                throw new IllegalStateException("superState must be null");
            case 1:
                return new A(parcel, classLoader);
            case 2:
                return new c0(parcel, classLoader);
            default:
                return new o0(parcel, classLoader);
        }
    }

    @Override // android.os.Parcelable.Creator
    public final Object[] newArray(int i4) {
        switch (this.f505a) {
            case 0:
                return new c[i4];
            case 1:
                return new A[i4];
            case 2:
                return new c0[i4];
            default:
                return new o0[i4];
        }
    }

    @Override // android.os.Parcelable.Creator
    public final Object createFromParcel(Parcel parcel) {
        switch (this.f505a) {
            case 0:
                if (parcel.readParcelable(null) == null) {
                    return c.f506b;
                }
                throw new IllegalStateException("superState must be null");
            case 1:
                return new A(parcel, null);
            case 2:
                return new c0(parcel, null);
            default:
                return new o0(parcel, null);
        }
    }
}
