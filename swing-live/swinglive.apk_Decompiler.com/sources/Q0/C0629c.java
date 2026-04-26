package q0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.common.internal.F;
import j1.C0454D;
import java.util.ArrayList;

/* JADX INFO: renamed from: q0.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0629c extends A0.a {
    public static final Parcelable.Creator<C0629c> CREATOR = new C0454D(7);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f6250a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final ArrayList f6251b;

    public C0629c(int i4, ArrayList arrayList) {
        this.f6250a = i4;
        F.g(arrayList);
        this.f6251b = arrayList;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f6250a);
        AbstractC0184a.l0(parcel, 2, this.f6251b, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
