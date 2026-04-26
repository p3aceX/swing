package z0;

import a.AbstractC0184a;
import android.app.PendingIntent;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.common.internal.r;
import com.google.android.gms.dynamite.descriptors.com.google.firebase.auth.ModuleDescriptor;
import java.util.Arrays;
import w0.C0701c;

/* JADX INFO: renamed from: z0.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0771b extends A0.a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f6948a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f6949b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final PendingIntent f6950c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final String f6951d;
    public static final C0771b e = new C0771b(0);
    public static final Parcelable.Creator<C0771b> CREATOR = new C0701c(4);

    public C0771b(int i4, int i5, PendingIntent pendingIntent, String str) {
        this.f6948a = i4;
        this.f6949b = i5;
        this.f6950c = pendingIntent;
        this.f6951d = str;
    }

    public static String b(int i4) {
        if (i4 == 99) {
            return "UNFINISHED";
        }
        if (i4 == 1500) {
            return "DRIVE_EXTERNAL_STORAGE_REQUIRED";
        }
        switch (i4) {
            case -1:
                return "UNKNOWN";
            case 0:
                return "SUCCESS";
            case 1:
                return "SERVICE_MISSING";
            case 2:
                return "SERVICE_VERSION_UPDATE_REQUIRED";
            case 3:
                return "SERVICE_DISABLED";
            case 4:
                return "SIGN_IN_REQUIRED";
            case 5:
                return "INVALID_ACCOUNT";
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                return "RESOLUTION_REQUIRED";
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                return "NETWORK_ERROR";
            case K.k.BYTES_FIELD_NUMBER /* 8 */:
                return "INTERNAL_ERROR";
            case 9:
                return "SERVICE_INVALID";
            case 10:
                return "DEVELOPER_ERROR";
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                return "LICENSE_CHECK_FAILED";
            default:
                switch (i4) {
                    case 13:
                        return "CANCELED";
                    case 14:
                        return "TIMEOUT";
                    case 15:
                        return "INTERRUPTED";
                    case 16:
                        return "API_UNAVAILABLE";
                    case 17:
                        return "SIGN_IN_FAILED";
                    case 18:
                        return "SERVICE_UPDATING";
                    case 19:
                        return "SERVICE_MISSING_PERMISSION";
                    case 20:
                        return "RESTRICTED_PROFILE";
                    case 21:
                        return "API_VERSION_UPDATE_REQUIRED";
                    case 22:
                        return "RESOLUTION_ACTIVITY_NOT_FOUND";
                    case 23:
                        return "API_DISABLED";
                    case 24:
                        return "API_DISABLED_FOR_CONNECTION";
                    default:
                        return B1.a.l("UNKNOWN_ERROR_CODE(", i4, ")");
                }
        }
    }

    public final boolean equals(Object obj) {
        if (obj == this) {
            return true;
        }
        if (!(obj instanceof C0771b)) {
            return false;
        }
        C0771b c0771b = (C0771b) obj;
        return this.f6949b == c0771b.f6949b && F.j(this.f6950c, c0771b.f6950c) && F.j(this.f6951d, c0771b.f6951d);
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{Integer.valueOf(this.f6949b), this.f6950c, this.f6951d});
    }

    public final String toString() {
        r rVar = new r(this);
        rVar.v(b(this.f6949b), "statusCode");
        rVar.v(this.f6950c, "resolution");
        rVar.v(this.f6951d, "message");
        return rVar.toString();
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f6948a);
        AbstractC0184a.o0(parcel, 2, 4);
        parcel.writeInt(this.f6949b);
        AbstractC0184a.h0(parcel, 3, this.f6950c, i4, false);
        AbstractC0184a.i0(parcel, 4, this.f6951d, false);
        AbstractC0184a.n0(iM0, parcel);
    }

    public C0771b(int i4) {
        this(1, i4, null, null);
    }

    public C0771b(int i4, PendingIntent pendingIntent) {
        this(1, i4, pendingIntent, null);
    }
}
