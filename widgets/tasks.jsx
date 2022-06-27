import { styled, css } from 'uebersicht';
import { round, uniqBy } from 'lodash';

export const command = '/opt/homebrew/bin/things.sh today';

export const refreshFrequency = 10 * 60 * 1000;

export const className = {
  bottom: 30,
  left: 50,
};

const baseViewStyle = {
  display: 'flex',
  flexDirection: 'column',
  boxSizing: 'border-box',
};

const Container = styled.ul({
  ...baseViewStyle,
  width: 300,
  fontFamily: 'SF Pro Rounded',
  color: 'white',
  height: '100%',
  margin: 0,
  padding: 0,
  // border: '1px solid red',
});

const Task = styled.li({
  margin: '6px 0',
  listStyleType: 'none',
  fontSize: 14,
  fontWeight: 500,
});

const Checkbox = styled.svg({
  width: 12,
  marginRight: 10,
  marginLeft: -10,
  marginBottom: -2,
});

export const render = ({ output, error }) => {
  const tasks = output
    .trim()
    .split('\n')
    .map((str) => {
      const [area, title, link] = str.split('|');
      return { area, title, link };
    });

  return (
    <Container>
      {/* <pre>{output}</pre> */}
      {tasks.map(({ title }) => (
        <Task>
          <Checkbox viewBox="0 0 448 512">
            <path
              fill="rgba(255, 255, 255)"
              d="M384 32C419.3 32 448 60.65 448 96V416C448 451.3 419.3 480 384 480H64C28.65 480 0 451.3 0 416V96C0 60.65 28.65 32 64 32H384zM384 80H64C55.16 80 48 87.16 48 96V416C48 424.8 55.16 432 64 432H384C392.8 432 400 424.8 400 416V96C400 87.16 392.8 80 384 80z"
            />
          </Checkbox>
          {title}
        </Task>
      ))}
    </Container>
  );
};
