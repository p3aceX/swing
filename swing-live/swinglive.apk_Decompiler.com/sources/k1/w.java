package k1;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.common.internal.F;

/* JADX INFO: loaded from: classes.dex */
public final class w implements A0.c {
    public static final Parcelable.Creator<w> CREATOR = new C0511b(5);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f5552a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f5553b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final boolean f5554c;

    public w(boolean z4) {
        this.f5554c = z4;
        this.f5553b = null;
        this.f5552a = null;
    }

    @Override // android.os.Parcelable
    public final int describeContents() {
        return 0;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.i0(parcel, 1, this.f5552a, false);
        AbstractC0184a.i0(parcel, 2, this.f5553b, false);
        AbstractC0184a.o0(parcel, 3, 4);
        parcel.writeInt(this.f5554c ? 1 : 0);
        AbstractC0184a.n0(iM0, parcel);
    }

    public w(String str, String str2, boolean z4) {
        F.d(str);
        F.d(str2);
        this.f5552a = str;
        this.f5553b = str2;
        k.d(str2);
        this.f5554c = z4;
    }
}
