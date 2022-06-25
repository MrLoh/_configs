import { styled, css } from 'uebersicht';
import { round, uniqBy } from 'lodash';
import dayjs from 'dayjs';

export const command = '/opt/homebrew/bin/icalBuddy -ea -iep "title,datetime,location" eventsToday';

export const refreshFrequency = 10 * 60 * 1000;

export const className = {
  top: 20,
  left: 50,
  height: 'calc(100vh - 300px)',
  opacity: 0.75,
  overflow: 'hidden',
};

const baseViewStyle = {
  display: 'flex',
  flexDirection: 'column',
  boxSizing: 'border-box',
};

const Container = styled.div({
  ...baseViewStyle,
  width: 300,
  fontFamily: 'SF Pro Rounded',
  color: 'white',
  height: '100%',
  // border: '1px solid red',
});

const CalendarDate = styled.h1({
  fontFamily: 'SF Pro Bold',
  fontWeight: 700,
  fontSize: 28,
  margin: 0,
  margin: '28px 0 12px',
});

const EventsList = styled.div({
  ...baseViewStyle,
  flex: 1,
  position: 'relative',
  margin: 0,
  padding: 0,
  //   border: '1px solid blue',
});

const EventBox = styled.div((p) => ({
  boxSizing: 'border-box',
  position: 'absolute',
  top: round(p.top * 100, 2) + '%',
  height: `calc(${round(p.len * 100, 2)}% - 5px)`,
  marginTop: 5,
  background: 'rgba(255,255,255,0.1)',
  overflow: 'hidden',
  padding: '4px 10px',
  borderRadius: '2px 10px 10px 2px',
  width: '100%',
  borderLeft: '2px solid rgba(255, 255, 255, 0.6)',
  //   backdropFilter: 'blur(10px)',
}));

const Time = styled.span({
  fontSize: 12,
  opacity: 0.6,
  fontWeight: 600,
  display: 'inline-block',
  marginBottom: 3,
});

const Title = styled.span((p) => ({
  fontSize: 14,
  fontWeight: 500,
  display: p.inline ? 'inline' : 'block',
  marginLeft: p.inline ? 10 : 0,
}));

const NowLine = styled.hr((p) => ({
  position: 'absolute',
  top: round(p.top * 100) + '%',
  width: '100%',
  background: 'white',
  height: 2,
  borderRadius: 2,
}));

const parseTime = (str) => {
  const today = new Date().toISOString().split('T')[0];
  return dayjs(`${today} ${str}`, 'YYYY-MM-DD HH:mm');
};

export const render = ({ output, error }) => {
  const events = output
    .split('• ')
    .slice(1)
    .map((str) => {
      const [title, ...details] = str
        .trim()
        .split('\n')
        .map((s) => s.trim());
      const [, calendar] = title.match(/\(([^()]+(\([^)]+\)[^)]*)*)\)/);
      const name = title.replace(`(${calendar})`, '').trim();
      const [time, location] = details.reverse();
      const [start, end] = time?.split(' - ').map(parseTime) ?? [];
      const duration = start && end && end.diff(start, 'minutes');
      return { name, start, end, location, calendar, duration };
    })
    .sort((a, b) => a.start > b.start);

  const dayStart = dayjs(Math.min(parseTime('10:00'), events[0].start));
  const dayEnd = dayjs(Math.max(parseTime('15:00'), events[events.length - 1].end));
  const dayLength = dayEnd.diff(dayStart, 'minutes');

  return (
    <Container>
      <CalendarDate>{dayjs().format('ddd MMM DD')}</CalendarDate>
      {/* <pre>{output}</pre> */}
      <EventsList>
        {uniqBy(events, 'name').map(({ name, location, start, end, duration, calendar }) => (
          <EventBox len={duration / dayLength} top={start.diff(dayStart, 'minutes') / dayLength}>
            <Time>
              {start?.format('HH:mm')}
              {/* – {end?.format('HH:mm')} ({duration}m) */}
            </Time>
            <Title inline={duration < 20}>{name}</Title>
          </EventBox>
        ))}
        <NowLine top={dayjs().diff(dayStart, 'minutes') / dayLength} />
      </EventsList>
    </Container>
  );
};
