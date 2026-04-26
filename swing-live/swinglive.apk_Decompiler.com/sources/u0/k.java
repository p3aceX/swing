package u0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.common.internal.F;
import j1.C0454D;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class k extends A0.a {
    public static final Parcelable.Creator<k> CREATOR = new C0454D(26);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final n f6620a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f6621b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f6622c;

    public k(n nVar, String str, int i4) {
        F.g(nVar);
        this.f6620a = nVar;
        this.f6621b = str;
        this.f6622c = i4;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof k)) {
            return false;
        }
        k kVar = (k) obj;
        return F.j(this.f6620a, kVar.f6620a) && F.j(this.f6621b, kVar.f6621b) && this.f6622c == kVar.f6622c;
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.f6620a, this.f6621b});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.h0(parcel, 1, this.f6620a, i4, false);
        AbstractC0184a.i0(parcel, 2, this.f6621b, false);
        AbstractC0184a.o0(parcel, 3, 4);
        parcel.writeInt(this.f6622c);
        AbstractC0184a.n0(iM0, parcel);
    }
}
