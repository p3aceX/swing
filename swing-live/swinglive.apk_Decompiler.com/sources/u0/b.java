package u0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.common.internal.F;
import j1.C0454D;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;

/* JADX INFO: loaded from: classes.dex */
public final class b extends A0.a {
    public static final Parcelable.Creator<b> CREATOR = new C0454D(20);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final boolean f6594a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f6595b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final String f6596c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final boolean f6597d;
    public final String e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final ArrayList f6598f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final boolean f6599m;

    public b(boolean z4, String str, String str2, boolean z5, String str3, ArrayList arrayList, boolean z6) {
        boolean z7 = true;
        if (z5 && z6) {
            z7 = false;
        }
        F.a("filterByAuthorizedAccounts and requestVerifiedPhoneNumber must not both be true; the Verified Phone Number feature only works in sign-ups.", z7);
        this.f6594a = z4;
        if (z4) {
            F.h(str, "serverClientId must be provided if Google ID tokens are requested");
        }
        this.f6595b = str;
        this.f6596c = str2;
        this.f6597d = z5;
        ArrayList arrayList2 = null;
        if (arrayList != null && !arrayList.isEmpty()) {
            arrayList2 = new ArrayList(arrayList);
            Collections.sort(arrayList2);
        }
        this.f6598f = arrayList2;
        this.e = str3;
        this.f6599m = z6;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof b)) {
            return false;
        }
        b bVar = (b) obj;
        return this.f6594a == bVar.f6594a && F.j(this.f6595b, bVar.f6595b) && F.j(this.f6596c, bVar.f6596c) && this.f6597d == bVar.f6597d && F.j(this.e, bVar.e) && F.j(this.f6598f, bVar.f6598f) && this.f6599m == bVar.f6599m;
    }

    public final int hashCode() {
        Boolean boolValueOf = Boolean.valueOf(this.f6594a);
        Boolean boolValueOf2 = Boolean.valueOf(this.f6597d);
        Boolean boolValueOf3 = Boolean.valueOf(this.f6599m);
        return Arrays.hashCode(new Object[]{boolValueOf, this.f6595b, this.f6596c, boolValueOf2, this.e, this.f6598f, boolValueOf3});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f6594a ? 1 : 0);
        AbstractC0184a.i0(parcel, 2, this.f6595b, false);
        AbstractC0184a.i0(parcel, 3, this.f6596c, false);
        AbstractC0184a.o0(parcel, 4, 4);
        parcel.writeInt(this.f6597d ? 1 : 0);
        AbstractC0184a.i0(parcel, 5, this.e, false);
        AbstractC0184a.j0(parcel, 6, this.f6598f);
        AbstractC0184a.o0(parcel, 7, 4);
        parcel.writeInt(this.f6599m ? 1 : 0);
        AbstractC0184a.n0(iM0, parcel);
    }
}
