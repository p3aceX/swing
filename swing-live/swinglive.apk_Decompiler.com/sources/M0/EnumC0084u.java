package M0;

import android.os.Parcel;
import android.os.Parcelable;
import java.util.Locale;

/* JADX INFO: renamed from: M0.u, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public enum EnumC0084u implements Parcelable {
    /* JADX INFO: Fake field, exist only in values array */
    NOT_SUPPORTED_ERR(9),
    /* JADX INFO: Fake field, exist only in values array */
    INVALID_STATE_ERR(11),
    /* JADX INFO: Fake field, exist only in values array */
    SECURITY_ERR(18),
    /* JADX INFO: Fake field, exist only in values array */
    NETWORK_ERR(19),
    /* JADX INFO: Fake field, exist only in values array */
    ABORT_ERR(20),
    /* JADX INFO: Fake field, exist only in values array */
    TIMEOUT_ERR(23),
    /* JADX INFO: Fake field, exist only in values array */
    ENCODING_ERR(27),
    /* JADX INFO: Fake field, exist only in values array */
    UNKNOWN_ERR(28),
    /* JADX INFO: Fake field, exist only in values array */
    CONSTRAINT_ERR(29),
    /* JADX INFO: Fake field, exist only in values array */
    DATA_ERR(30),
    /* JADX INFO: Fake field, exist only in values array */
    NOT_ALLOWED_ERR(35),
    /* JADX INFO: Fake field, exist only in values array */
    ATTESTATION_NOT_PRIVATE_ERR(36);

    public static final Parcelable.Creator<EnumC0084u> CREATOR = new W(17);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f1037a;

    EnumC0084u(int i4) {
        this.f1037a = i4;
    }

    public static EnumC0084u a(int i4) throws C0083t {
        for (EnumC0084u enumC0084u : values()) {
            if (i4 == enumC0084u.f1037a) {
                return enumC0084u;
            }
        }
        Locale locale = Locale.US;
        throw new C0083t(B1.a.l("Error code ", i4, " is not supported"));
    }

    @Override // android.os.Parcelable
    public final int describeContents() {
        return 0;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        parcel.writeInt(this.f1037a);
    }
}
