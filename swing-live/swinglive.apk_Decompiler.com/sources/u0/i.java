package u0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.common.internal.F;
import j1.C0454D;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class i extends A0.a {
    public static final Parcelable.Creator<i> CREATOR = new C0454D(19);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f6614a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f6615b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final String f6616c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final String f6617d;
    public final boolean e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final int f6618f;

    public i(String str, String str2, String str3, String str4, boolean z4, int i4) {
        F.g(str);
        this.f6614a = str;
        this.f6615b = str2;
        this.f6616c = str3;
        this.f6617d = str4;
        this.e = z4;
        this.f6618f = i4;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof i)) {
            return false;
        }
        i iVar = (i) obj;
        return F.j(this.f6614a, iVar.f6614a) && F.j(this.f6617d, iVar.f6617d) && F.j(this.f6615b, iVar.f6615b) && F.j(Boolean.valueOf(this.e), Boolean.valueOf(iVar.e)) && this.f6618f == iVar.f6618f;
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.f6614a, this.f6615b, this.f6617d, Boolean.valueOf(this.e), Integer.valueOf(this.f6618f)});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.i0(parcel, 1, this.f6614a, false);
        AbstractC0184a.i0(parcel, 2, this.f6615b, false);
        AbstractC0184a.i0(parcel, 3, this.f6616c, false);
        AbstractC0184a.i0(parcel, 4, this.f6617d, false);
        AbstractC0184a.o0(parcel, 5, 4);
        parcel.writeInt(this.e ? 1 : 0);
        AbstractC0184a.o0(parcel, 6, 4);
        parcel.writeInt(this.f6618f);
        AbstractC0184a.n0(iM0, parcel);
    }
}
